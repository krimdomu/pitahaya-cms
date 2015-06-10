#!//bin/bash

indexer --all "$@"
exec searchd --nodetach
