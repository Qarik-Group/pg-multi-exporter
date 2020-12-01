#!/bin/sh

ytt -f /templates --file-mark '**/*.sh:type=text-template' --output-files /etc
