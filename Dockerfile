# Source: https://github.com/GoogleContainerTools/distroless#examples-with-docker
# Start by building the application.
FROM golang@sha256:25de7b6b28219279a409961158c547aadd0960cf2dcbc533780224afa1157fd4 AS base

WORKDIR /go/src/app
COPY . .

RUN CGO_ENABLED=0 go build -o /go/bin/app

# Now copy it into our base image.
FROM gcr.io/google-appengine/debian10@sha256:d2e40ef81a0f353f1b9c3cf07e384a1f23db3acdaa0eae4c269b653ab45ffadf
COPY --from=base /go/bin/app /
ENTRYPOINT [ "/app" ]
