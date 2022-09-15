module.exports = {
	env: {
		browser: true,
		es2021: true,
	},
	extends: ["eslint:recommended", "xo", "prettier"],
	parserOptions: {
		ecmaVersion: "latest",
		sourceType: "module",
	},
	rules: {},
};
