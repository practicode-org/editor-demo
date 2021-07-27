# practicode-editor

## Project setup
```
npm install
```

### Compiles and hot-reloads for development
```
npm run serve
```

### Compiles and minifies for production
```
npm run build
```

### Lints and fixes files
```
npm run lint
```

### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).

### nginx Dockerfile
Dockerfile expects following env variables
```
          env:
            - name: PRACTICODE_BACKEND_ENDPOINT
              value: {{ .Values.backend.hostName }}
            - name: PRACTICODE_CLIENT_HOST
              value: http://{{ .Values.client.hostName }}
            - name: PRACTICODE_RUNJAIL_WEBSOCKET
              value: ws://{{ .Values.runjail.hostName }}/run
```
