package main

import (
	"fmt"
	"net/http"
	"net/url"
	"strconv"
	"strings"
)

func getPrometheusTimeout(r *http.Request, defaultTimeout float64) (timeout float64, err error) {
	// If a timeout is configured via the Prometheus header, add it to the request.
	if v := r.Header.Get("X-Prometheus-Scrape-Timeout-Seconds"); v != "" {
		timeout, err = strconv.ParseFloat(v, 64)
		if err != nil {
			return
		}
	}
	if timeout == 0 {
		timeout = defaultTimeout
	}

	return
}

func paramsGetWithDefault(params url.Values, name, defaultValue string) (value string) {
	value = params.Get(name)
	if value == "" {
		value = defaultValue
	}
	return
}

func paramsGetRequired(params url.Values, name string) (value string, err error) {
	value = params.Get(name)
	if value == "" {
		err = fmt.Errorf("parameter \"%v\" is missing", name)
	}

	return
}

func paramsGetList(params url.Values, name string) (list []string, err error) {
	for _, v := range params[name] {
		sublist := strings.Split(v, ",")
		for _, item := range sublist {
			list = append(list, item)
		}
	}
	return
}

func paramsGetListRequired(params url.Values, name string) (list []string, err error) {
	list, err = paramsGetList(params, name)

	if len(list) == 0 {
		err = fmt.Errorf("parameter \"%v\" is missing", name)
		return
	}

	return
}

func boolToFloat64(b bool) float64 {
	if b {
		return 1
	}
	return 0
}

func boolToString(b bool) string {
	if b {
		return "true"
	}
	return "false"
}

func intToString(v int) string {
	return strconv.FormatInt(int64(v), 10)
}

func int64ToString(v int64) string {
	return strconv.FormatInt(v, 10)
}

func float32ToString(v float32) string {
	return strconv.FormatFloat(float64(v), 'f', 6, 64)
}

func float64ToString(v float64) string {
	return strconv.FormatFloat(v, 'f', 6, 64)
}

func stringPtrToString(v *string) string {
	if v == nil {
		return ""
	}

	return *v
}
