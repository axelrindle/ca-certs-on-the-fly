package cacertsonthefly_test

import (
	"context"
	"io"
	"regexp"
	"strings"
	"testing"
	"time"

	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

var regex = regexp.MustCompile(`(-----BEGIN CERTIFICATE-----(\n|\r|\r\n)([0-9a-zA-Z\+\/=]{64}(\n|\r|\r\n))*([0-9a-zA-Z\+\/=]{1,63}(\n|\r|\r\n))?-----END CERTIFICATE-----)`)

func TestBasic(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 1*time.Minute)
	defer cancel()

	container, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
		Started: true,
		ContainerRequest: testcontainers.ContainerRequest{
			FromDockerfile: testcontainers.FromDockerfile{
				Context:   ".",
				KeepImage: false,
			},
			WaitingFor: wait.NewFileStrategy("/tmp/certs/ca-certificates.crt"),
		},
	})
	if err != nil {
		t.Error(err)
	}
	defer testcontainers.CleanupContainer(t, container)

	r, err := container.CopyFileFromContainer(ctx, "/tmp/certs/ca-certificates.crt")
	if err != nil {
		t.Error(err)
	}

	buffer := &strings.Builder{}
	_, err = io.Copy(buffer, r)
	if err != nil {
		t.Error(err)
	}

	s := buffer.String()
	if !regex.MatchString(s) {
		t.Error("ca-certificates.crt not in PEM format")
	}
}
