#!/bin/bash
docker buildx create --name buildx-builder
docker buildx use buildx-builder 
docker buildx inspect --bootstrap