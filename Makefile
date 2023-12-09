SDK := $(shell xcrun --sdk iphoneos --show-sdk-path)
CC := xcrun --sdk iphoneos clang

TARGET := proxyctl
SOURCES := proxyctl.m
OBJECTS := $(SOURCES:.m=.o)
ENTITLEMENTS := ent.xml
INSTALL_DIR := /usr/bin

HEADERS := $(CURDIR)
PRIVATE_HEADERS := $(CURDIR)/iPhoneOS16.5.sdk/System/Library/PrivateFrameworks

ARCHS := -arch arm64 -arch arm64e
CFLAGS := --sysroot=$(SDK) $(ARCHS) -target apple-ios12.0 -F$(PRIVATE_HEADERS) -I$(HEADERS)
LDFLAGS := -framework Foundation -framework WiFiKit

TMP_DIR := /private/var/tmp
DEB_CONTROL := layout/DEBIAN/control
DEB_BUNDLE_ID := org.kostyshyn.proxyctl
DEB_BUNDLE_VER := 0.0.1
DEB_NAME := $(DEB_BUNDLE_ID)-$(DEB_BUNDLE_VER).deb

all: $(TARGET) sign deb-gen #deb-install

test: all install run-w run-wo

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

%.o: %.m
	$(CC) $(CFLAGS) -c $< -o $@

sign:
	codesign -f -s - --entitlements $(ENTITLEMENTS) $(TARGET)

install:
	ssh iphone "rm -f $(INSTALL_DIR)/$(TARGET)"
	scp -O $(TARGET) iphone:$(INSTALL_DIR)/

run-w:
	ssh iphone "$(INSTALL_DIR)/$(TARGET) localhost 8080"

run-wo:
	ssh iphone "$(INSTALL_DIR)/$(TARGET)"

deb-gen:
	sed -i "" "s/Package: .*/Package: $(DEB_BUNDLE_ID)/" $(DEB_CONTROL)
	sed -i "" "s/Name: .*/Name: $(TARGET)/" $(DEB_CONTROL)
	sed -i "" "s/Version: .*/Version: $(DEB_BUNDLE_VER)/" $(DEB_CONTROL)
	mkdir -p layout$(INSTALL_DIR)
	cp $(TARGET) layout$(INSTALL_DIR)
	dpkg-deb -b layout/ $(DEB_NAME)

deb-install:
	ssh iphone "dpkg -r $(DEB_BUNDLE_ID)"
	scp -O $(DEB_NAME) iphone:$(TMP_DIR)/
	ssh iphone "dpkg -i $(TMP_DIR)/$(DEB_NAME)"
	ssh iphone "rm $(TMP_DIR)/$(DEB_NAME)"

clean:
	rm -f $(OBJECTS) $(TARGET) $(DEB_NAME)

.PHONY: all clean sign install test run-w run-wo
