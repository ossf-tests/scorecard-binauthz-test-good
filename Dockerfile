# Source: https://github.com/GoogleContainerTools/distroless#examples-with-docker
# Start by building the application.
FROM golang@sha256:25de7b6b28219279a409961158c547aadd0960cf2dcbc533780224afa1157fd4 AS base

WORKDIR /go/src/app
COPY . .

RUN CGO_ENABLED=0 go build -o /go/bin/app

# Now copy it into our base image.
FROM gcr.io/distroless/static-debian11@sha256:44835b2602c3c437bcb58ee141302b842ba428d473ed131c601c474ce865c09b
COPY --from=build /go/bin/app /
CMD ["/app"]
