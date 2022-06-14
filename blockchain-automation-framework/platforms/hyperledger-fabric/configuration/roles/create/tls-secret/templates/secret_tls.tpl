kind: Secret
apiVersion: v1
metadata:
  name: {{ secret_name }}
  namespace: {{ secret_namespace }}
type: kubernetes.io/tls
data:
    tls.crt: {{ server_crt_base64 }}
    tls.key: {{ server_key_base64 }}