package main

import (
	"bytes"
	"fmt"
	"os"
	"strings"
	"text/template"
)

var servers = []Server{
	{
		Host:      "code.home.lubui.com",
		UpStream:  "127.0.0.1:7007",
		EnableSSO: true,
	},
}

type Server struct {
	Host           string
	UpStream       string
	LocationOfHtml string
	EnableSSO      bool
}

func getEnvMap() map[string]string {
	envMap := map[string]string{}
	for _, e := range os.Environ() {
		spl := strings.SplitN(e, "=", 2)
		envMap[spl[0]] = spl[1]
	}
	return envMap
}

func panicIfErr(err error) {
	if err != nil {
		panic(err)
	}
}

func main() {
	tmplPath := os.Args[1]
	destPath := os.Args[2]

	var buf bytes.Buffer
	panicIfErr(template.Must(template.ParseFiles(tmplPath)).Execute(&buf, map[string]any{
		"Servers": servers,
		"Env":     getEnvMap(),
	}))
	fmt.Println(string(buf.String()))
	os.WriteFile(destPath, buf.Bytes(), 0644)
}
