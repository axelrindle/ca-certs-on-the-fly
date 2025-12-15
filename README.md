# ca-certs-on-the-fly

> 📜 Generate a ca-certificates.crt file on the fly

Makes use of the debian [ca-certificates](https://salsa.debian.org/debian/ca-certificates) project
to generate a combined `ca-certificates.crt` file.

## Usage

Prepare your custom CA certificates to be available in the PEM (`.pem`/`.crt`) format and mount
them into the container at `/usr/local/share/ca-certificates`.

The result file will be `/etc/ssl/certs/ca-certificates.crt`. You can copy it to another
volume for consuming by other applications.

### Docker

```shell
docker run --name gen-ca-certs \
    --rm -it \
    -v ./ca-certificates:/usr/local/share/ca-certificates:ro \
    axelrindle/ca-certs-on-the-fly
```

### Kubernetes

<details>

<summary>Init Container for Deployment</summary>

```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: gen-ca-certs-hooks
data:
  copy-result.sh: |
    #!/bin/bash
    cp /etc/ssl/certs/ca-certificates.crt /mnt/ca-certificates

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      volumes:
        - name: kube-root-ca
          configMap:
            name: kube-root-ca.crt
        - name: ca-hooks
          configMap:
            name: gen-ca-certs-hooks
            defaultMode: 0755
        - name: ca-certificates
          emptyDir: {}
      initContainers:
      - name: gen-ca-certs
        image: axelrindle/ca-certs-on-the-fly
        imagePullPolicy: Always
        volumeMounts:
          - name: kube-root-ca
            mountPath: /usr/local/share/ca-certificates/custom
            readOnly: true
          - name: ca-hooks
            mountPath: /etc/ca-certificates/update.d
            readOnly: true
          - name: ca-certificates
            mountPath: /mnt/ca-certificates
      containers:
      - name: myapp
        image: myorg/myapp:mytag
        resources:
          requests:
            memory: "16Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 1337
```

</details>

## Hooks

Custom shell scripts and other executable files placed in `/etc/ca-certificates/update.d`
will be run after a `ca-certificates.crt` has been generated.

## License

[The Unlicense](LICENSE)
