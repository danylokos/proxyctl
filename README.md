# proxyctl

This util allows you to control iOS proxy settings via CLI on a jailbroken device.

Run `make` to build, `make install` to install on device (assuming you have your device configured and reachable as `iphone` in `~/.ssh/config`) or install DEB-package manually.

```sh
$ ssh iphone proxyctl localhost 8080
proxyctl[6938:181870] Settings for SSID "YourNetwork":
	WFSettingsProxy- Server: localhost  Port: 8080
proxyctl[6938:181870] Proxy enabled
```

```sh
$ ssh iphone proxyctl
proxyctl[6945:182052] Settings for SSID "YourNetwork":
	WFSettingsProxy- Server: (null)  Port: (null)
proxyctl[6945:182052] Proxy disabled
```
