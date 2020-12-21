package main

import (
	"context"
	"crypto/sha256"
	"fmt"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"github.com/remeh/sizedwaitgroup"
	log "github.com/sirupsen/logrus"
	prometheusCommon "github.com/webdevops/go-prometheus-common"
	"net/http"
	"time"
)

func probeMetricsListHandler(w http.ResponseWriter, r *http.Request) {
	var err error
	var timeoutSeconds float64
	wg := sizedwaitgroup.New(opts.Prober.ConcurrencySubscription)

	startTime := time.Now()

	contextLogger := buildContextLoggerFromRequest(r)

	// If a timeout is configured via the Prometheus header, add it to the request.
	timeoutSeconds, err = getPrometheusTimeout(r, ProbeMetricsListTimeoutDefault)
	if err != nil {
		contextLogger.Error(err)
		http.Error(w, fmt.Sprintf("failed to parse timeout from Prometheus header: %s", err), http.StatusInternalServerError)
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), time.Duration(timeoutSeconds*float64(time.Second)))
	defer cancel()
	r = r.WithContext(ctx)

	var settings RequestMetricSettings
	if settings, err = NewRequestMetricSettings(r); err != nil {
		contextLogger.Errorln(err)
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	registry, metricGauge := azureInsightMetrics.CreatePrometheusRegistryAndMetricsGauge(settings.Name)
	metricsList := prometheusCommon.NewMetricsList()
	metricsList.SetCache(metricsCache)

	cacheKey := fmt.Sprintf("probeMetricsListHandler::%x", sha256.Sum256([]byte(r.URL.String())))
	loadedFromCache := false
	if settings.Cache != nil {
		loadedFromCache = metricsList.LoadFromCache(cacheKey)
	}

	if !loadedFromCache {
		w.Header().Add("X-metrics-cached", "false")
		for _, subscription := range settings.Subscriptions {
			wg.Add()
			go func(subscription string) {
				defer wg.Done()
				wgResource := sizedwaitgroup.New(opts.Prober.ConcurrencySubscriptionResource)

				// fetch list of resources
				list, err := azureInsightMetrics.ListResources(subscription, settings.Filter)

				if err != nil {
					contextLogger.Errorln(err)
					http.Error(w, err.Error(), http.StatusBadRequest)
					return
				}

				for list.NotDone() {
					val := list.Value()

					wgResource.Add()
					go func() {
						defer wgResource.Done()
						result, err := azureInsightMetrics.FetchMetrics(ctx, subscription, *val.ID, settings)

						resourceLogger := contextLogger.WithFields(log.Fields{
							"azureSubscription": subscription,
							"azureResource":     *val.ID,
						})

						if err == nil {
							resourceLogger.Debugf("fetched metrics for %v", *val.ID)
							result.SetGauge(metricsList, settings)
							prometheusMetricRequests.With(prometheus.Labels{
								"subscriptionID": subscription,
								"handler":        ProbeMetricsListUrl,
								"filter":         settings.Filter,
								"result":         "success",
							}).Inc()
						} else {
							resourceLogger.Debugf("failed fetching metrics for %v", *val.ID)
							resourceLogger.Warningln(err)

							prometheusMetricRequests.With(prometheus.Labels{
								"subscriptionID": subscription,
								"handler":        ProbeMetricsListUrl,
								"filter":         settings.Filter,
								"result":         "error",
							}).Inc()
						}
					}()

					if list.NextWithContext(ctx) != nil {
						break
					}
				}

				wgResource.Wait()

				// global stats counter
				prometheusCollectTime.With(prometheus.Labels{
					"subscriptionID": subscription,
					"handler":        ProbeMetricsListUrl,
					"filter":         settings.Filter,
				}).Observe(time.Now().Sub(startTime).Seconds())

			}(subscription)
		}

		wg.Wait()

		// enable caching if enabled
		if cacheDuration := settings.CacheDuration(startTime); cacheDuration != nil {
			metricsList.StoreToCache(cacheKey, *cacheDuration)
			w.Header().Add("X-metrics-cached-until", time.Now().Add(*cacheDuration).Format(time.RFC3339))
		}
	} else {
		w.Header().Add("X-metrics-cached", "true")
		prometheusMetricRequests.With(prometheus.Labels{
			"subscriptionID": "",
			"handler":        ProbeMetricsListUrl,
			"filter":         settings.Filter,
			"result":         "cached",
		}).Inc()
	}

	metricsList.GaugeSet(metricGauge)

	h := promhttp.HandlerFor(registry, promhttp.HandlerOpts{})
	h.ServeHTTP(w, r)
}
