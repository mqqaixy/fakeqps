ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

THEOS_PACKAGE_SCHEME = rootless

TWEAK_NAME = FakeLocationPro
FakeLocationPro_FILES = Tweak.x
FakeLocationPro_FRAMEWORKS = UIKit CoreLocation MapKit

include $(THEOS_MAKE_PATH)/tweak.mk
after-all::
    @echo "Obj dir contents:"
    @ls -la $(THEOS_OBJ_DIR) || true
    @echo "dylib size:"
    @ls -lh $(THEOS_OBJ_DIR)/$(TWEAK_NAME).dylib || true
    @echo "Symbols in dylib:"
    @nm $(THEOS_OBJ_DIR)/$(TWEAK_NAME).dylib | grep -E "handleFake|customLat|spoofing" || true
