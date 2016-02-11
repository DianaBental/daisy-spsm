./match-manager.sh convert $1 $1.xml -config=../conf/s-match-Tab2XML.properties -property=ContextLoader=it.unitn.disi.smatch.loaders.context.FileFunctionLoader
./match-manager.sh convert $2 $2.xml -config=../conf/s-match-Tab2XML.properties -property=ContextLoader=it.unitn.disi.smatch.loaders.context.FileFunctionLoader
./match-manager.sh offline $1.xml $1.xml
./match-manager.sh offline $2.xml $2.xml
./match-manager.sh online $1.xml $2.xml $3 -config=../conf/s-match-spsm-prolog.properties -property=ContextLoader=it.unitn.disi.smatch.loaders.context.SimpleXMLContextLoader
