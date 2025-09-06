.PHONY: shots clean shots-light shots-dark help

# Professional screenshot generation for App Store
# Based on ChatGPT's superior solution

help:
	@echo "📸 Professional iOS Screenshot Generator"
	@echo ""
	@echo "Available commands:"
	@echo "  make shots       - Generate all screenshots (light + dark mode)"
	@echo "  make shots-light - Generate only light mode screenshots"
	@echo "  make shots-dark  - Generate only dark mode screenshots"  
	@echo "  make clean       - Clean screenshot output directory"
	@echo "  make help        - Show this help"
	@echo ""

shots:
	@echo "🚀 Generating professional App Store screenshots..."
	@bash tools/shots.sh tools/shots.json

shots-light:
	@echo "🌞 Generating light mode screenshots..."
	@jq '.appearances = ["light"]' tools/shots.json > tools/shots-light.json
	@bash tools/shots.sh tools/shots-light.json
	@rm tools/shots-light.json

shots-dark:
	@echo "🌙 Generating dark mode screenshots..." 
	@jq '.appearances = ["dark"]' tools/shots.json > tools/shots-dark.json
	@bash tools/shots.sh tools/shots-dark.json
	@rm tools/shots-dark.json

clean:
	@echo "🧹 Cleaning screenshots..."
	@rm -rf shots
	@echo "✅ Screenshots cleaned"