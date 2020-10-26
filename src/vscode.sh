-- For VSCODE Extensions
		- Install NodeJS
		- Install package to create news extensions
			1. npm install -g yo
			2. npm install -g typescript
			2. npm install -g yo generator-code
			3. yo code
		- Generate VSIX
			1. npm install -g vsce
			2. cd myExtension
				* Generate: vsce package
				* Published to VS Code MarketPlace: vsce publish