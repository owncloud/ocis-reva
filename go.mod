module github.com/owncloud/ocis-reva

go 1.13

require (
	github.com/cs3org/reva v0.1.1-0.20200320145721-40c4334849c3
	github.com/gofrs/uuid v3.2.0+incompatible
	github.com/micro/cli/v2 v2.1.1
	github.com/oklog/run v1.0.0
	github.com/owncloud/ocis-pkg/v2 v2.0.1
	github.com/restic/calens v0.2.0
	github.com/spf13/viper v1.6.1
)

replace github.com/cs3org/reva => ../../refs/reva
