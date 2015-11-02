{
	"package": {
		"name": "prorab",
		"repo": "deb",
		"subject": "igagis"
	},
	
	"version": {
		"name": "all"
	},

	"files": [
		{
			"includePattern": "../(.[^/]*(\\.deb)$)",
			"uploadPattern": "$1"
		}
	],
	"publish": true,
	"override": false
}
