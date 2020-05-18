def main(ctx):
  before = [
    testing(ctx),
    apiTests(ctx),
    uiTests(ctx),
  ]

  stages = [
    docker(ctx, 'amd64'),
    docker(ctx, 'arm64'),
    docker(ctx, 'arm'),
    binary(ctx, 'linux'),
    binary(ctx, 'darwin'),
    binary(ctx, 'windows'),
  ]

  after = [
    manifest(ctx),
    changelog(ctx),
    readme(ctx),
    badges(ctx),
    website(ctx),
  ]

  return before + stages + after

def apiTests(ctx):
  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': 'API-Tests',
    'platform': {
      'os': 'linux',
      'arch': 'amd64',
    },
    'steps': [
      {
        'name': 'build',
        'image': 'webhippie/golang:1.13',
        'pull': 'always',
        'commands': [
          'make build',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'reva-server',
        'image': 'webhippie/golang:1.13',
        'pull': 'always',
        'detach': True,
        'environment' : {
          'REVA_LDAP_HOSTNAME': 'ldap',
          'REVA_LDAP_PORT': 636,
          'REVA_LDAP_BIND_DN': 'cn=admin,dc=owncloud,dc=com',
          'REVA_LDAP_BIND_PASSWORD': 'admin',
          'REVA_LDAP_BASE_DN': 'dc=owncloud,dc=com',
          'REVA_LDAP_SCHEMA_DISPLAYNAME': 'displayName',
          'REVA_STORAGE_HOME_DATA_TEMP_FOLDER': '/srv/app/tmp/',
          'REVA_STORAGE_OWNCLOUD_DATADIR': '/srv/app/tmp/reva/data',
          'REVA_STORAGE_OC_DATA_TEMP_FOLDER': '/srv/app/tmp/',
          'REVA_STORAGE_OWNCLOUD_REDIS_ADDR': 'redis:6379',
          'REVA_SHARING_USER_JSON_FILE': '/srv/app/tmp/reva/shares.json'
        },
        'commands': [
          'mkdir -p /srv/app/tmp/reva',
          'bin/ocis-reva gateway &',
          'bin/ocis-reva users &',
          'bin/ocis-reva auth-basic &',
          'bin/ocis-reva auth-bearer &',
          'bin/ocis-reva sharing &',
          'bin/ocis-reva storage-home &',
          'bin/ocis-reva storage-home-data &',
          'bin/ocis-reva storage-oc &',
          'bin/ocis-reva storage-oc-data &',
          'bin/ocis-reva frontend'
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ]
      },
      {
        'name': 'acceptance-tests',
        'image': 'owncloudci/php:7.2',
        'pull': 'always',
        'environment' : {
          'TEST_SERVER_URL': 'http://reva-server:9140',
          'BEHAT_FILTER_TAGS': '~@skipOnOcis&&~@skipOnLDAP&&@TestAlsoOnExternalUserBackend&&~@local_storage',
          'REVA_LDAP_HOSTNAME':'ldap',
          'TEST_EXTERNAL_USER_BACKENDS':'true',
          'TEST_OCIS':'true',
          'OCIS_REVA_DATA_ROOT': '/srv/app/tmp/reva/',
          'SKELETON_DIR': '/srv/app/tmp/testing/data/apiSkeleton'
         },
         'commands': [
           'git clone -b master --depth=1 https://github.com/owncloud/testing.git /srv/app/tmp/testing',
           'git clone -b shareAutocompletion-20200518 --depth=1 https://github.com/owncloud/core.git /srv/app/testrunner',
           'cd /srv/app/testrunner',
           'make test-acceptance-api'
          ],
          'volumes': [
            {
              'name': 'gopath',
              'path': '/srv/app',
            },
          ]
      },
    ],
    'services': [
      {
        'name': 'ldap',
        'image': 'osixia/openldap',
        'pull': 'always',
        'environment': {
          'LDAP_DOMAIN': 'owncloud.com',
          'LDAP_ORGANISATION': 'owncloud',
          'LDAP_ADMIN_PASSWORD': 'admin',
          'LDAP_TLS_VERIFY_CLIENT': 'never',
          'HOSTNAME': 'ldap'
         },
      },
      {
        'name': 'redis',
        'image': 'webhippie/redis',
        'pull': 'always',
        'environment': {
          'REDIS_DATABASES': 1
         },
      },
    ],
    'volumes': [
      {
        'name': 'gopath',
        'temp': {},
      },
    ],
    'trigger': {
      'ref': [
        'refs/heads/master',
        'refs/tags/**',
        'refs/pull/**',
      ],
    },
  }

def testing(ctx):
  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': 'testing',
    'platform': {
      'os': 'linux',
      'arch': 'amd64',
    },
    'steps': [
      {
        'name': 'generate',
        'image': 'webhippie/golang:1.13',
        'pull': 'always',
        'commands': [
          'make generate',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'vet',
        'image': 'webhippie/golang:1.13',
        'pull': 'always',
        'commands': [
          'make vet',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'staticcheck',
        'image': 'webhippie/golang:1.13',
        'pull': 'always',
        'commands': [
          'make staticcheck',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'lint',
        'image': 'webhippie/golang:1.13',
        'pull': 'always',
        'commands': [
          'make lint',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'build',
        'image': 'webhippie/golang:1.13',
        'pull': 'always',
        'commands': [
          'make build',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'test',
        'image': 'webhippie/golang:1.13',
        'pull': 'always',
        'commands': [
          'make test',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'codacy',
        'image': 'plugins/codacy:1',
        'pull': 'always',
        'settings': {
          'token': {
            'from_secret': 'codacy_token',
          },
        },
      },
      {
        'name': 'reva-server',
        'image': 'webhippie/golang:1.13',
        'pull': 'always',
        'detach': True,
        'environment' : {
          'REVA_LDAP_HOSTNAME': 'ldap',
          'REVA_LDAP_PORT': 636,
          'REVA_LDAP_BIND_DN': 'cn=admin,dc=owncloud,dc=com',
          'REVA_LDAP_BIND_PASSWORD': 'admin',
          'REVA_LDAP_BASE_DN': 'dc=owncloud,dc=com',
          'REVA_LDAP_SCHEMA_DISPLAYNAME': 'displayName',
          'REVA_STORAGE_HOME_DATA_TEMP_FOLDER': '/srv/app/tmp/',
          'REVA_STORAGE_OWNCLOUD_DATADIR': '/srv/app/tmp/reva/data',
          'REVA_STORAGE_OC_DATA_TEMP_FOLDER': '/srv/app/tmp/',
          'REVA_STORAGE_OWNCLOUD_REDIS_ADDR': 'redis:6379',
          'REVA_SHARING_USER_JSON_FILE': '/srv/app/tmp/reva/shares.json',
          'REVA_OIDC_ISSUER': 'https://konnectd:9130',
        },
        'commands': [
          'mkdir -p /srv/app/tmp/reva',
          'bin/ocis-reva gateway &',
          'bin/ocis-reva users &',
          'bin/ocis-reva auth-basic &',
          'bin/ocis-reva auth-bearer &',
          'bin/ocis-reva sharing &',
          'bin/ocis-reva storage-home &',
          'bin/ocis-reva storage-home-data &',
          'bin/ocis-reva storage-oc &',
          'bin/ocis-reva storage-oc-data &',
          'bin/ocis-reva frontend'
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ]
      },
      {
        'name': 'import-litmus-users',
        'image': 'emeraldsquad/ldapsearch',
        'pull': 'always',
        'commands': [
          'ldapadd -h ldap -p 389 -D "cn=admin,dc=owncloud,dc=com" -w admin -f ./tests/data/testusers.ldif',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'litmus',
        'image': 'owncloud/litmus:latest',
        'pull': 'always',
        'environment' : {
          'LITMUS_URL': 'http://reva-server:9140/remote.php/webdav',
          'LITMUS_USERNAME': 'tu1',
          'LITMUS_PASSWORD': '1234',
          'TESTS': 'basic http copymove'
         },
      },
    ],
    'services': [
      {
        'name': 'ldap',
        'image': 'osixia/openldap',
        'pull': 'always',
        'environment': {
          'LDAP_DOMAIN': 'owncloud.com',
          'LDAP_ORGANISATION': 'owncloud',
          'LDAP_ADMIN_PASSWORD': 'admin',
          'LDAP_TLS_VERIFY_CLIENT': 'never',
          'HOSTNAME': 'ldap'
         },
      },
      {
        'name': 'redis',
        'image': 'webhippie/redis',
        'pull': 'always',
        'environment': {
          'REDIS_DATABASES': 1
         },
      },
    ],
    'volumes': [
      {
        'name': 'gopath',
        'temp': {},
      },
      {
        'name': 'config',
        'temp': {},
      },
      {
        'name': 'uploads',
        'temp': {},
      },
    ],
    'trigger': {
      'ref': [
        'refs/heads/master',
        'refs/tags/**',
        'refs/pull/**',
      ],
    },
  }

def uiTests(ctx):
 return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': 'Phoenix-UI-Tests',
    'platform': {
      'os': 'linux',
      'arch': 'amd64',
    },
    'steps': [
      {
        'name': 'build',
        'image': 'webhippie/golang:1.13',
        'pull': 'always',
        'commands': [
          'make build',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'copy-config',
        'image': 'webhippie/golang:1.13',
        'commands': [
           'mkdir -p /srv/config/drone',
           'ls -la tests/config',
           'cp -r tests/config/config.json /srv/config/drone',
           'cp -r tests/config/identifier-registration.yml /srv/config/drone',
           'ls -la /srv/config/drone',
         ],
         'volumes': [
           {
             'name': 'config',
             'path': '/srv/config',
           },
        ]
      },
      {
        'name': 'konnectd',
        'image': 'owncloud/ocis-konnectd',
        'pull': 'always',
        'detach': True,
        'environment': {
          'LDAP_BASEDN': 'ou=TestUsers,dc=owncloud,dc=com',
          'LDAP_BINDDN': 'cn=admin,dc=owncloud,dc=com',
          'LDAP_URI': 'ldap://ldap:389',
          'KONNECTD_IDENTIFIER_REGISTRATION_CONF': '/srv/config/drone/identifier-registration.yml',
          'KONNECTD_ISS': 'https://konnectd:9130',
          'KONNECTD_TLS': 'true',
          'LDAP_BINDPW': 'admin',
          'LDAP_SCOPE': 'sub',
          'LDAP_LOGIN_ATTRIBUTE': 'uid',
          'LDAP_EMAIL_ATTRIBUTE': 'mail',
          'LDAP_NAME_ATTRIBUTE': 'givenName',
          'LDAP_UUID_ATTRIBUTE': 'uid',
          'LDAP_UUID_ATTRIBUTE_TYPE': 'text',
          'LDAP_FILTER': "(objectClass=posixaccount)"
        },
        'volumes': [
          {
            'name': 'config',
            'path': '/srv/config',
          },
        ]
      },
      {
        'name': 'phoenix',
        'image': 'owncloud/ocis-phoenix',
        'pull': 'always',
        'detach': True,
        'environment': {
            'PHOENIX_WEB_CONFIG': '/srv/config/drone/config.json',
            'PHOENIX_OIDC_CLIENT_ID': 'phoenix'
        },
        'volumes': [
          {
            'name': 'config',
            'path': '/srv/config',
          },
        ]
      },
      {
        'name': 'reva-server',
        'image': 'webhippie/golang:1.13',
        'pull': 'always',
        'detach': True,
        'environment' : {
          'REVA_LDAP_HOSTNAME': 'ldap',
          'REVA_LDAP_PORT': 636,
          'REVA_LDAP_BIND_DN': 'cn=admin,dc=owncloud,dc=com',
          'REVA_LDAP_BIND_PASSWORD': 'admin',
          'REVA_LDAP_BASE_DN': 'dc=owncloud,dc=com',
          'REVA_LDAP_SCHEMA_DISPLAYNAME': 'displayName',
          'REVA_STORAGE_HOME_DATA_TEMP_FOLDER': '/srv/app/tmp/',
          'REVA_STORAGE_OWNCLOUD_DATADIR': '/srv/app/tmp/reva/data',
          'REVA_STORAGE_OC_DATA_TEMP_FOLDER': '/srv/app/tmp/',
          'REVA_STORAGE_OWNCLOUD_REDIS_ADDR': 'redis:6379',
          'REVA_SHARING_USER_JSON_FILE': '/srv/app/tmp/reva/shares.json',
          'REVA_OIDC_ISSUER': 'https://konnectd:9130',
        },
        'commands': [
          'mkdir -p /srv/app/tmp/reva',
          'bin/ocis-reva gateway &',
          'bin/ocis-reva users &',
          'bin/ocis-reva auth-basic &',
          'bin/ocis-reva auth-bearer &',
          'bin/ocis-reva sharing &',
          'bin/ocis-reva storage-home &',
          'bin/ocis-reva storage-home-data &',
          'bin/ocis-reva storage-oc &',
          'bin/ocis-reva storage-oc-data &',
          'bin/ocis-reva frontend'
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ]
      },
      {
        'name': 'ui-tests',
        'image': 'owncloudci/nodejs:11',
        'pull': 'always',
        'environment' : {
          'TEST_TAGS': 'not @skipOnOCIS and not @skip',
          'REVA_LDAP_HOSTNAME':'ldap',
          'SERVER_HOST': 'http://phoenix:9100',
          'BACKEND_HOST': 'http://reva-server:9140',
          'SELENIUM_PORT': '4444',
          'RUN_ON_OCIS': 'true',
          'OCIS_SKELETON_DIR': '/srv/app/testingapp/data/webUISkeleton',
          'OCIS_REVA_DATA_ROOT': '/srv/app/tmp/reva/',
          'LDAP_SERVER_URL': 'ldap://ldap',
          'PHOENIX_CONFIG': '/srv/config/drone/config.json',
          'TEST_CONTEXT': '',
          'LOCAL_UPLOAD_DIR': '/uploads',
        },
        'commands': [
          'ls -la /srv/config/drone',
          'git clone https://github.com/owncloud/testing.git /srv/app/testingapp',
          'git clone -b master --depth=1 https://github.com/owncloud/phoenix.git /srv/app/uitestrunner',
          'cd /srv/app/uitestrunner',
          'yarn install --all',
          'yarn run acceptance-tests-drone'
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
          {
            'name': 'config',
            'path': '/srv/config',
          },
          {
            'name': 'uploads',
            'path': '/srv/app/phoenix/tests/acceptance/uitestrunner',
          },
        ]
      },
    ],
    'services': [
      {
        'name': 'ldap',
        'image': 'osixia/openldap',
        'pull': 'always',
        'environment': {
          'LDAP_DOMAIN': 'owncloud.com',
          'LDAP_ORGANISATION': 'owncloud',
          'LDAP_ADMIN_PASSWORD': 'admin',
          'LDAP_TLS_VERIFY_CLIENT': 'never',
          'HOSTNAME': 'ldap'
         },
      },
      {
        'name': 'selenium',
        'image': 'selenium/standalone-chrome-debug:3.141.59-20200326',
        'pull': 'always',
        'volumes': [{
          'name': 'uploads',
          'path': '/uploads'
        }],
      },
      {
        'name': 'redis',
        'image': 'webhippie/redis',
        'pull': 'always',
        'environment': {
          'REDIS_DATABASES': 1
         },
      },
    ],
    'volumes': [
      {
        'name': 'gopath',
        'temp': {},
      },
      {
        'name': 'config',
        'temp': {},
      },
      {
        'name': 'uploads',
        'temp': {},
      },
    ],
    'trigger': {
      'ref': [
        'refs/heads/master',
        'refs/tags/**',
        'refs/pull/**',
      ],
    },
  }

def docker(ctx, arch):
  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': arch,
    'platform': {
      'os': 'linux',
      'arch': arch,
    },
    'steps': [
      {
        'name': 'generate',
        'image': 'webhippie/golang:1.13',
        'pull': 'always',
        'commands': [
          'make generate',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'build',
        'image': 'webhippie/golang:1.13',
        'pull': 'always',
        'commands': [
          'make build',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'dryrun',
        'image': 'plugins/docker:18.09',
        'pull': 'always',
        'settings': {
          'dry_run': True,
          'tags': 'linux-%s' % (arch),
          'dockerfile': 'docker/Dockerfile.linux.%s' % (arch),
          'repo': ctx.repo.slug,
        },
        'when': {
          'ref': {
            'include': [
              'refs/pull/**',
            ],
          },
        },
      },
      {
        'name': 'docker',
        'image': 'plugins/docker:18.09',
        'pull': 'always',
        'settings': {
          'username': {
            'from_secret': 'docker_username',
          },
          'password': {
            'from_secret': 'docker_password',
          },
          'auto_tag': True,
          'auto_tag_suffix': 'linux-%s' % (arch),
          'dockerfile': 'docker/Dockerfile.linux.%s' % (arch),
          'repo': ctx.repo.slug,
        },
        'when': {
          'ref': {
            'exclude': [
              'refs/pull/**',
            ],
          },
        },
      },
    ],
    'volumes': [
      {
        'name': 'gopath',
        'temp': {},
      },
    ],
    'depends_on': [
      'testing',
    ],
    'trigger': {
      'ref': [
        'refs/heads/master',
        'refs/tags/**',
        'refs/pull/**',
      ],
    },
  }

def binary(ctx, name):
  if ctx.build.event == "tag":
    settings = {
      'endpoint': {
        'from_secret': 's3_endpoint',
      },
      'access_key': {
        'from_secret': 'aws_access_key_id',
      },
      'secret_key': {
        'from_secret': 'aws_secret_access_key',
      },
      'bucket': {
        'from_secret': 's3_bucket',
      },
      'path_style': True,
      'strip_prefix': 'dist/release/',
      'source': 'dist/release/*',
      'target': '/ocis/%s/%s' % (ctx.repo.name.replace("ocis-", ""), ctx.build.ref.replace("refs/tags/v", "")),
    }
  else:
    settings = {
      'endpoint': {
        'from_secret': 's3_endpoint',
      },
      'access_key': {
        'from_secret': 'aws_access_key_id',
      },
      'secret_key': {
        'from_secret': 'aws_secret_access_key',
      },
      'bucket': {
        'from_secret': 's3_bucket',
      },
      'path_style': True,
      'strip_prefix': 'dist/release/',
      'source': 'dist/release/*',
      'target': '/ocis/%s/testing' % (ctx.repo.name.replace("ocis-", "")),
    }

  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': name,
    'platform': {
      'os': 'linux',
      'arch': 'amd64',
    },
    'steps': [
      {
        'name': 'generate',
        'image': 'webhippie/golang:1.13',
        'pull': 'always',
        'commands': [
          'make generate',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'build',
        'image': 'webhippie/golang:1.13',
        'pull': 'always',
        'commands': [
          'make release-%s' % (name),
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'finish',
        'image': 'webhippie/golang:1.13',
        'pull': 'always',
        'commands': [
          'make release-finish',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'upload',
        'image': 'plugins/s3:1',
        'pull': 'always',
        'settings': settings,
        'when': {
          'ref': [
            'refs/heads/master',
            'refs/tags/**',
          ],
        },
      },
      {
        'name': 'changelog',
        'image': 'toolhippie/calens:latest',
        'pull': 'always',
        'commands': [
          'calens --version %s -o dist/CHANGELOG.md' % ctx.build.ref.replace("refs/tags/v", "").split("-")[0],
        ],
        'when': {
          'ref': [
            'refs/tags/**',
          ],
        },
      },
      {
        'name': 'release',
        'image': 'plugins/github-release:1',
        'pull': 'always',
        'settings': {
          'api_key': {
            'from_secret': 'github_token',
          },
          'files': [
            'dist/release/*',
          ],
          'title': ctx.build.ref.replace("refs/tags/v", ""),
          'note': 'dist/CHANGELOG.md',
          'overwrite': True,
          'prerelease': len(ctx.build.ref.split("-")) > 1,
        },
        'when': {
          'ref': [
            'refs/tags/**',
          ],
        },
      },
    ],
    'volumes': [
      {
        'name': 'gopath',
        'temp': {},
      },
    ],
    'depends_on': [
      'testing',
    ],
    'trigger': {
      'ref': [
        'refs/heads/master',
        'refs/tags/**',
        'refs/pull/**',
      ],
    },
  }

def manifest(ctx):
  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': 'manifest',
    'platform': {
      'os': 'linux',
      'arch': 'amd64',
    },
    'steps': [
      {
        'name': 'execute',
        'image': 'plugins/manifest:1',
        'pull': 'always',
        'settings': {
          'username': {
            'from_secret': 'docker_username',
          },
          'password': {
            'from_secret': 'docker_password',
          },
          'spec': 'docker/manifest.tmpl',
          'auto_tag': True,
          'ignore_missing': True,
        },
      },
    ],
    'depends_on': [
      'amd64',
      'arm64',
      'arm',
      'linux',
      'darwin',
      'windows',
    ],
    'trigger': {
      'ref': [
        'refs/heads/master',
        'refs/tags/**',
      ],
    },
  }

def changelog(ctx):
  repo_slug = ctx.build.source_repo if ctx.build.source_repo else ctx.repo.slug
  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': 'changelog',
    'platform': {
      'os': 'linux',
      'arch': 'amd64',
    },
    'clone': {
      'disable': True,
    },
    'steps': [
      {
        'name': 'clone',
        'image': 'plugins/git-action:1',
        'pull': 'always',
        'settings': {
          'actions': [
            'clone',
          ],
          'remote': 'https://github.com/%s' % (repo_slug),
          'branch': ctx.build.source if ctx.build.event == 'pull_request' else 'master',
          'path': '/drone/src',
          'netrc_machine': 'github.com',
          'netrc_username': {
            'from_secret': 'github_username',
          },
          'netrc_password': {
            'from_secret': 'github_token',
          },
        },
      },
      {
        'name': 'generate',
        'image': 'webhippie/golang:1.13',
        'pull': 'always',
        'commands': [
          'make changelog',
        ],
      },
      {
        'name': 'diff',
        'image': 'owncloud/alpine:latest',
        'pull': 'always',
        'commands': [
          'git diff',
        ],
      },
      {
        'name': 'output',
        'image': 'owncloud/alpine:latest',
        'pull': 'always',
        'commands': [
          'cat CHANGELOG.md',
        ],
      },
      {
        'name': 'publish',
        'image': 'plugins/git-action:1',
        'pull': 'always',
        'settings': {
          'actions': [
            'commit',
            'push',
          ],
          'message': 'Automated changelog update [skip ci]',
          'branch': 'master',
          'author_email': 'devops@owncloud.com',
          'author_name': 'ownClouders',
          'netrc_machine': 'github.com',
          'netrc_username': {
            'from_secret': 'github_username',
          },
          'netrc_password': {
            'from_secret': 'github_token',
          },
        },
        'when': {
          'ref': {
            'exclude': [
              'refs/pull/**',
            ],
          },
        },
      },
    ],
    'depends_on': [
      'manifest',
    ],
    'trigger': {
      'ref': [
        'refs/heads/master',
        'refs/pull/**',
      ],
    },
  }

def readme(ctx):
  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': 'readme',
    'platform': {
      'os': 'linux',
      'arch': 'amd64',
    },
    'steps': [
      {
        'name': 'execute',
        'image': 'sheogorath/readme-to-dockerhub:latest',
        'pull': 'always',
        'environment': {
          'DOCKERHUB_USERNAME': {
            'from_secret': 'docker_username',
          },
          'DOCKERHUB_PASSWORD': {
            'from_secret': 'docker_password',
          },
          'DOCKERHUB_REPO_PREFIX': ctx.repo.namespace,
          'DOCKERHUB_REPO_NAME': ctx.repo.name,
          'SHORT_DESCRIPTION': 'Docker images for %s' % (ctx.repo.name),
          'README_PATH': 'README.md',
        },
      },
    ],
    'depends_on': [
      'changelog',
    ],
    'trigger': {
      'ref': [
        'refs/heads/master',
        'refs/tags/**',
      ],
    },
  }

def badges(ctx):
  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': 'badges',
    'platform': {
      'os': 'linux',
      'arch': 'amd64',
    },
    'steps': [
      {
        'name': 'execute',
        'image': 'plugins/webhook:1',
        'pull': 'always',
        'settings': {
          'urls': {
            'from_secret': 'microbadger_url',
          },
        },
      },
    ],
    'depends_on': [
      'readme',
    ],
    'trigger': {
      'ref': [
        'refs/heads/master',
        'refs/tags/**',
      ],
    },
  }

def website(ctx):
  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': 'website',
    'platform': {
      'os': 'linux',
      'arch': 'amd64',
    },
    'steps': [
      {
        'name': 'prepare',
        'image': 'owncloudci/alpine:latest',
        'commands': [
          'make docs-copy'
        ],
      },
      {
        'name': 'test',
        'image': 'webhippie/hugo:latest',
        'commands': [
          'cd hugo',
          'hugo',
        ],
      },
      {
        'name': 'list',
        'image': 'owncloudci/alpine:latest',
        'commands': [
          'tree hugo/public',
        ],
      },
      {
        'name': 'publish',
        'image': 'plugins/gh-pages:1',
        'pull': 'always',
        'settings': {
          'username': {
            'from_secret': 'github_username',
          },
          'password': {
            'from_secret': 'github_token',
          },
          'pages_directory': 'docs/',
          'target_branch': 'docs',
        },
        'when': {
          'ref': {
            'exclude': [
              'refs/pull/**',
            ],
          },
        },
      },
      {
        'name': 'downstream',
        'image': 'plugins/downstream',
        'settings': {
          'server': 'https://cloud.drone.io/',
          'token': {
            'from_secret': 'drone_token',
          },
          'repositories': [
            'owncloud/owncloud.github.io@source',
          ],
        },
        'when': {
          'ref': {
            'exclude': [
              'refs/pull/**',
            ],
          },
        },
      },
    ],
    'depends_on': [
      'badges',
    ],
    'trigger': {
      'ref': [
        'refs/heads/master',
        'refs/pull/**',
      ],
    },
  }
