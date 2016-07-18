var Travis = require('travis-ci');

// change this
var repo = "haxeui/haxeui-openfl";

var travis = new Travis({
	version: '2.0.0'
});

travis.authenticate({

	// available through Travis CI
	// see: http://kamranicus.com/blog/2015/02/26/continuous-deployment-with-travis-ci/
	github_token: process.env.GH_TOKEN

}, function (err, res) {
	if (err) {
		return console.error(err);
	}

	travis.repos(repo.split('/')[0], repo.split('/')[1]).builds.get(function (err, res) {
		if (err) {
			return console.error(err);
		}

		travis.requests.post({
			build_id: res.builds[0].id
		}, function (err, res) {
			if (err) {
				return console.error(err);
			}
			console.log(res.flash[0].notice);
		});
	});
});