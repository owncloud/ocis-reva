package flagset

import (
	"os"

	"github.com/micro/cli/v2"
	"github.com/owncloud/ocis-reva/pkg/config"
)

// StoragePublicLink applies cfg to the root flagset
func StoragePublicLink(cfg *config.Config) []cli.Flag {
	return []cli.Flag{

		&cli.BoolFlag{
			Name:        "tracing-enabled",
			Usage:       "Enable sending traces",
			EnvVars:     []string{"REVA_TRACING_ENABLED"},
			Destination: &cfg.Tracing.Enabled,
		},
		&cli.StringFlag{
			Name:        "tracing-type",
			Value:       "jaeger",
			Usage:       "Tracing backend type",
			EnvVars:     []string{"REVA_TRACING_TYPE"},
			Destination: &cfg.Tracing.Type,
		},
		&cli.StringFlag{
			Name:        "tracing-endpoint",
			Value:       "",
			Usage:       "Endpoint for the agent",
			EnvVars:     []string{"REVA_TRACING_ENDPOINT"},
			Destination: &cfg.Tracing.Endpoint,
		},
		&cli.StringFlag{
			Name:        "tracing-collector",
			Value:       "",
			Usage:       "Endpoint for the collector",
			EnvVars:     []string{"REVA_TRACING_COLLECTOR"},
			Destination: &cfg.Tracing.Collector,
		},
		&cli.StringFlag{
			Name:        "tracing-service",
			Value:       "reva",
			Usage:       "Service name for tracing",
			EnvVars:     []string{"REVA_TRACING_SERVICE"},
			Destination: &cfg.Tracing.Service,
		},

		// debug ports are the odd ports
		&cli.StringFlag{
			Name:        "debug-addr",
			Value:       "0.0.0.0:9155",
			Usage:       "Address to bind debug server",
			EnvVars:     []string{"REVA_STORAGE_PUBLIC_LINK_DEBUG_ADDR"},
			Destination: &cfg.Reva.StoragePublicLink.DebugAddr,
		},
		&cli.StringFlag{
			Name:        "debug-token",
			Value:       "",
			Usage:       "Token to grant metrics access",
			EnvVars:     []string{"REVA_DEBUG_TOKEN"},
			Destination: &cfg.Debug.Token,
		},
		&cli.BoolFlag{
			Name:        "debug-pprof",
			Usage:       "Enable pprof debugging",
			EnvVars:     []string{"REVA_DEBUG_PPROF"},
			Destination: &cfg.Debug.Pprof,
		},
		&cli.BoolFlag{
			Name:        "debug-zpages",
			Usage:       "Enable zpages debugging",
			EnvVars:     []string{"REVA_DEBUG_ZPAGES"},
			Destination: &cfg.Debug.Zpages,
		},

		// REVA

		&cli.StringFlag{
			Name:        "jwt-secret",
			Value:       "Pive-Fumkiu4",
			Usage:       "Shared jwt secret for reva service communication",
			EnvVars:     []string{"REVA_JWT_SECRET"},
			Destination: &cfg.Reva.JWTSecret,
		},

		// Services

		// Storage home

		&cli.StringFlag{
			Name:        "network",
			Value:       "tcp",
			Usage:       "Network to use for the reva service, can be 'tcp', 'udp' or 'unix'",
			EnvVars:     []string{"REVA_STORAGE_PUBLIC_LINK_NETWORK"},
			Destination: &cfg.Reva.StoragePublicLink.Network,
		},
		&cli.StringFlag{
			Name:        "protocol",
			Value:       "grpc",
			Usage:       "protocol for reva service, can be 'http' or 'grpc'",
			EnvVars:     []string{"REVA_STORAGE_PUBLIC_LINK_PROTOCOL"},
			Destination: &cfg.Reva.StoragePublicLink.Protocol,
		},
		&cli.StringFlag{
			Name:        "addr",
			Value:       "0.0.0.0:10054",
			Usage:       "Address to bind reva service",
			EnvVars:     []string{"REVA_STORAGE_PUBLIC_LINK_ADDR"},
			Destination: &cfg.Reva.StoragePublicLink.Addr,
		},
		&cli.StringFlag{
			Name:        "url",
			Value:       "localhost:10054",
			Usage:       "URL to use for the reva service",
			EnvVars:     []string{"REVA_STORAGE_PUBLIC_LINK_URL"},
			Destination: &cfg.Reva.StoragePublicLink.URL,
		},
		&cli.StringSliceFlag{
			Name:    "service",
			Value:   cli.NewStringSlice("storageprovider"),
			Usage:   "--service storageprovider [--service otherservice]",
			EnvVars: []string{"REVA_STORAGE_PUBLIC_LINK_SERVICES"},
		},

		&cli.StringFlag{
			Name:        "public_share_provider_addr",
			Value:       "localhost:9150",
			Usage:       "public share provider service address",
			EnvVars:     []string{"REVA_STORAGE_PUBLICLINK_PUBLIC_SHARE_PROVIDER_ADDR"},
			Destination: &cfg.Reva.StoragePublicLink.PublicShareProviderAddr,
		},
		&cli.StringFlag{
			Name:        "user_provider_addr",
			Value:       "localhost:9144",
			Usage:       "user provider service address",
			EnvVars:     []string{"REVA_STORAGE_PUBLICLINK_USER_PROVIDER_ADDR"},
			Destination: &cfg.Reva.StoragePublicLink.UserProviderAddr,
		},
		&cli.StringFlag{
			Name:        "storage_provider_addr",
			Value:       "localhost:9154",
			Usage:       "storage provider service address",
			EnvVars:     []string{"REVA_STORAGE_PUBLICLINK_STORAGE_PROVIDER_ADDR"},
			Destination: &cfg.Reva.StoragePublicLink.StorageProviderAddr,
		},

		&cli.StringFlag{
			Name:        "driver",
			Value:       "owncloud",
			Usage:       "storage driver, eg. local, eos, owncloud or s3",
			EnvVars:     []string{"REVA_STORAGE_PUBLIC_LINK_DRIVER"},
			Destination: &cfg.Reva.StoragePublicLink.Driver,
		},
		&cli.StringFlag{
			Name:        "mount-path",
			Value:       "/public-links",
			Usage:       "mount path",
			EnvVars:     []string{"REVA_STORAGE_PUBLIC_LINK_MOUNT_PATH"},
			Destination: &cfg.Reva.StoragePublicLink.MountPath,
		},
		&cli.StringFlag{
			Name:        "mount-id",
			Value:       "123e4567-e89b-12d3-a456-426655440000",
			Usage:       "mount id",
			EnvVars:     []string{"REVA_STORAGE_PUBLIC_LINK_MOUNT_ID"},
			Destination: &cfg.Reva.StoragePublicLink.MountID,
		},
		&cli.BoolFlag{
			Name:        "expose-data-server",
			Value:       true,
			Usage:       "exposes a dedicated data server",
			EnvVars:     []string{"REVA_STORAGE_PUBLIC_LINK_EXPOSE_DATA_SERVER"},
			Destination: &cfg.Reva.StoragePublicLink.ExposeDataServer,
		},
		&cli.StringFlag{
			Name:        "data-server-url",
			Value:       "http://localhost:9156/data",
			Usage:       "data server url",
			EnvVars:     []string{"REVA_STORAGE_PUBLIC_LINK_DATA_SERVER_URL"},
			Destination: &cfg.Reva.StoragePublicLink.DataServerURL,
		},
		&cli.BoolFlag{
			Name:        "enable-home-creation",
			Value:       true,
			Usage:       "if enabled home dirs will be automatically created",
			EnvVars:     []string{"REVA_STORAGE_PUBLIC_LINK_ENABLE_HOME_CREATION"},
			Destination: &cfg.Reva.StoragePublicLink.EnableHomeCreation,
		},

		// Storage drivers

		// Eos

		&cli.StringFlag{
			Name:        "storage-eos-namespace",
			Value:       "",
			Usage:       "Namespace for metadata operations",
			EnvVars:     []string{"REVA_STORAGE_EOS_NAMESPACE"},
			Destination: &cfg.Reva.Storages.EOS.Namespace,
		},
		&cli.StringFlag{
			Name:        "storage-eos-binary",
			Value:       "/usr/bin/eos",
			Usage:       "Location of the eos binary",
			EnvVars:     []string{"REVA_STORAGE_EOS_BINARY"},
			Destination: &cfg.Reva.Storages.EOS.EosBinary,
		},
		&cli.StringFlag{
			Name:        "storage-eos-xrdcopy-binary",
			Value:       "/usr/bin/xrdcopy",
			Usage:       "Location of the xrdcopy binary",
			EnvVars:     []string{"REVA_STORAGE_EOS_XRDCOPY_BINARY"},
			Destination: &cfg.Reva.Storages.EOS.XrdcopyBinary,
		},
		&cli.StringFlag{
			Name:        "storage-eos-master-url",
			Value:       "root://eos-example.org",
			Usage:       "URL of the Master EOS MGM",
			EnvVars:     []string{"REVA_STORAGE_EOS_MASTER_URL"},
			Destination: &cfg.Reva.Storages.EOS.MasterURL,
		},
		&cli.StringFlag{
			Name:        "storage-eos-slave-url",
			Value:       "root://eos-example.org",
			Usage:       "URL of the Slave EOS MGM",
			EnvVars:     []string{"REVA_STORAGE_EOS_SLAVE_URL"},
			Destination: &cfg.Reva.Storages.EOS.SlaveURL,
		},
		&cli.StringFlag{
			Name:        "storage-eos-cache-directory",
			Value:       os.TempDir(),
			Usage:       "Location on the local fs where to store reads",
			EnvVars:     []string{"REVA_STORAGE_EOS_CACHE_DIRECTORY"},
			Destination: &cfg.Reva.Storages.EOS.CacheDirectory,
		},
		&cli.BoolFlag{
			Name:        "storage-eos-enable-logging",
			Usage:       "Enables logging of the commands executed",
			EnvVars:     []string{"REVA_STORAGE_EOS_ENABLE_LOGGING"},
			Destination: &cfg.Reva.Storages.EOS.EnableLogging,
		},
		&cli.BoolFlag{
			Name:        "storage-eos-show-hidden-sysfiles",
			Usage:       "show internal EOS files like .sys.v# and .sys.a# files.",
			EnvVars:     []string{"REVA_STORAGE_EOS_SHOW_HIDDEN_SYSFILES"},
			Destination: &cfg.Reva.Storages.EOS.ShowHiddenSysFiles,
		},
		&cli.BoolFlag{
			Name:        "storage-eos-force-singleuser-mode",
			Usage:       "force connections to EOS to use SingleUsername",
			EnvVars:     []string{"REVA_STORAGE_EOS_FORCE_SINGLEUSER_MODE"},
			Destination: &cfg.Reva.Storages.EOS.ForceSingleUserMode,
		},
		&cli.BoolFlag{
			Name:        "storage-eos-use-keytab",
			Usage:       "authenticate requests by using an EOS keytab",
			EnvVars:     []string{"REVA_STORAGE_EOS_USE_KEYTAB"},
			Destination: &cfg.Reva.Storages.EOS.UseKeytab,
		},
		&cli.BoolFlag{
			Name:        "storage-eos-enable-home",
			Usage:       "enable the creation of home directories",
			EnvVars:     []string{"REVA_STORAGE_EOS_ENABLE_HOME"},
			Destination: &cfg.Reva.Storages.EOS.EnableHome,
		},
		&cli.StringFlag{
			Name:        "storage-eos-sec-protocol",
			Value:       "",
			Usage:       "the xrootd security protocol to use between the server and EOS",
			EnvVars:     []string{"REVA_STORAGE_EOS_SEC_PROTOCOL"},
			Destination: &cfg.Reva.Storages.EOS.SecProtocol,
		},
		&cli.StringFlag{
			Name:        "storage-eos-keytab",
			Value:       "",
			Usage:       "the location of the keytab to use to authenticate to EOS",
			EnvVars:     []string{"REVA_STORAGE_EOS_KEYTAB"},
			Destination: &cfg.Reva.Storages.EOS.Keytab,
		},
		&cli.StringFlag{
			Name:        "storage-eos-single-username",
			Value:       "",
			Usage:       "the username to use when SingleUserMode is enabled",
			EnvVars:     []string{"REVA_STORAGE_EOS_SINGLE_USERNAME"},
			Destination: &cfg.Reva.Storages.EOS.SingleUsername,
		},
		&cli.StringFlag{
			Name:        "storage-eos-layout",
			Value:       "{{.Username}}",
			Usage:       `"layout of the users home dir path on disk, in addition to {{.Username}}, {{.UsernameLower}} and {{.Provider}} also supports prefixing dirs: "{{.UsernamePrefixCount.2}}/{{.UsernameLower}}" will turn "Einstein" into "Ei/Einstein" `,
			EnvVars:     []string{"REVA_STORAGE_EOS_LAYOUT"},
			Destination: &cfg.Reva.Storages.EOS.Layout,
		},

		// local

		&cli.StringFlag{
			Name:        "storage-local-root",
			Value:       "/var/tmp/reva/root",
			Usage:       "the path to the local storage root",
			EnvVars:     []string{"REVA_STORAGE_LOCAL_ROOT"},
			Destination: &cfg.Reva.Storages.Local.Root,
		},

		// owncloud

		&cli.StringFlag{
			Name:        "storage-owncloud-datadir",
			Value:       "/var/tmp/reva/data",
			Usage:       "the path to the owncloud data directory",
			EnvVars:     []string{"REVA_STORAGE_OWNCLOUD_DATADIR"},
			Destination: &cfg.Reva.Storages.OwnCloud.Datadirectory,
		},
		&cli.BoolFlag{
			Name:        "storage-owncloud-scan",
			Value:       true,
			Usage:       "scan files on startup to add fileids",
			EnvVars:     []string{"REVA_STORAGE_OWNCLOUD_SCAN"},
			Destination: &cfg.Reva.Storages.OwnCloud.Scan,
		},
		&cli.StringFlag{
			Name:        "storage-owncloud-redis",
			Value:       ":6379",
			Usage:       "the address of the redis server",
			EnvVars:     []string{"REVA_STORAGE_OWNCLOUD_REDIS_ADDR"},
			Destination: &cfg.Reva.Storages.OwnCloud.Redis,
		},
		&cli.BoolFlag{
			Name:        "storage-owncloud-enable-home",
			Value:       true,
			Usage:       "enable the creation of home storages",
			EnvVars:     []string{"REVA_STORAGE_OWNCLOUD_ENABLE_HOME"},
			Destination: &cfg.Reva.Storages.OwnCloud.EnableHome,
		},
		&cli.StringFlag{
			Name:        "storage-owncloud-layout",
			Value:       "{{.Username}}",
			Usage:       `"layout of the users home dir path on disk, in addition to {{.Username}}, {{.UsernameLower}} and {{.Provider}} also supports prefixing dirs: "{{.UsernamePrefixCount.2}}/{{.UsernameLower}}" will turn "Einstein" into "Ei/Einstein" `,
			EnvVars:     []string{"REVA_STORAGE_OWNCLOUD_LAYOUT"},
			Destination: &cfg.Reva.Storages.OwnCloud.Layout,
		},
	}
}
