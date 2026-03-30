# ─────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────
PROJECT         = TagYourCar.xcodeproj
SCHEME_IOS      = TagYourCar
BUNDLE_ID_IOS   = com.tagyourcar.app

IOS_SIM_NAME    = iPhone 17 Pro
IOS_DEST        = platform=iOS Simulator,name=$(IOS_SIM_NAME)

BUILD_DIR       = .build/xcode
LOG_DIR         = .build/logs
ARCHIVE_DIR     = .build/archive

# ─────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────
.PHONY: help
help:
	@echo "Commandes disponibles :"
	@echo "  make build      → build iOS simulator"
	@echo "  make run        → build + install + launch iOS simulator"
	@echo "  make test       → tests unitaires"
	@echo "  make generate   → generer xcodeproj via XcodeGen"
	@echo "  make devices    → liste devices"
	@echo "  make doctor     → diagnostic setup"
	@echo "  make logs       → lire les logs de build"
	@echo "  make clean      → nettoyage"

# ─────────────────────────────────────────────
# Generate Xcode project
# ─────────────────────────────────────────────
.PHONY: generate
generate:
	@echo "▶ Generation du projet Xcode..."
	xcodegen generate
	@echo "✅ Projet genere"

# ─────────────────────────────────────────────
# Build iOS Simulator
# ─────────────────────────────────────────────
.PHONY: build
build:
	@mkdir -p $(LOG_DIR)
	@echo "▶ Build iOS Simulator..."
	xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME_IOS) \
		-destination '$(IOS_DEST)' \
		-configuration Debug \
		-derivedDataPath $(BUILD_DIR) \
		CODE_SIGNING_ALLOWED=NO \
		2>&1 | tee $(LOG_DIR)/ios_build.log | tail -5
	@echo "✅ Build iOS termine"

# ─────────────────────────────────────────────
# Run iOS Simulator
# ─────────────────────────────────────────────
.PHONY: run
run: build
	@echo "▶ Boot simulator $(IOS_SIM_NAME)..."
	@open -a Simulator
	@xcrun simctl boot "$(IOS_SIM_NAME)" 2>/dev/null || true
	@sleep 2
	@APP_PATH=$$(find $(BUILD_DIR) -name "$(SCHEME_IOS).app" -path "*/Debug-iphonesimulator/*" | head -1); \
	if [ -z "$$APP_PATH" ]; then echo "❌ App iOS introuvable"; exit 1; fi; \
	echo "▶ Install $$APP_PATH"; \
	xcrun simctl install booted "$$APP_PATH"; \
	echo "▶ Launch $(BUNDLE_ID_IOS)"; \
	xcrun simctl launch booted $(BUNDLE_ID_IOS) || true
	@echo "✅ App iOS lancee"

# ─────────────────────────────────────────────
# Tests
# ─────────────────────────────────────────────
.PHONY: test
test:
	@mkdir -p $(LOG_DIR)
	xcodebuild test \
		-project $(PROJECT) \
		-scheme $(SCHEME_IOS) \
		-destination '$(IOS_DEST)' \
		-derivedDataPath $(BUILD_DIR) \
		CODE_SIGNING_ALLOWED=NO \
		2>&1 | tee $(LOG_DIR)/tests.log | tail -10

# ─────────────────────────────────────────────
# Devices list
# ─────────────────────────────────────────────
.PHONY: devices
devices:
	@xcrun simctl list devices available | grep -i "iphone\|apple tv"

# ─────────────────────────────────────────────
# Logs
# ─────────────────────────────────────────────
.PHONY: logs
logs:
	@cat $(LOG_DIR)/ios_build.log 2>/dev/null || echo "Pas de log de build"

# ─────────────────────────────────────────────
# Doctor
# ─────────────────────────────────────────────
.PHONY: doctor
doctor:
	@echo "▶ Xcode" && xcodebuild -version || true
	@echo "▶ Swift" && swift --version || true
	@echo "▶ XcodeGen" && xcodegen --version || true
	@echo "▶ Simulators" && xcrun simctl list devices available | grep -i "iphone" | head -5

# ─────────────────────────────────────────────
# Clean
# ─────────────────────────────────────────────
.PHONY: clean
clean:
	@rm -rf $(BUILD_DIR) $(LOG_DIR) $(ARCHIVE_DIR)
	@echo "Clean termine"
