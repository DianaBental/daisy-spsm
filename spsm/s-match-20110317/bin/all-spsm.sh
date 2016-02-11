./match-manager.sh convert ../test-data/spsm/source.txt ../test-data/spsm/source.xml -config=../conf/s-match-Tab2XML.properties -property=ContextLoader=it.unitn.disi.smatch.loaders.context.FileFunctionLoader
./match-manager.sh convert ../test-data/spsm/target.txt ../test-data/spsm/target.xml -config=../conf/s-match-Tab2XML.properties -property=ContextLoader=it.unitn.disi.smatch.loaders.context.FileFunctionLoader
./match-manager.sh offline ../test-data/spsm/source.xml ../test-data/spsm/source.xml
./match-manager.sh offline ../test-data/spsm/target.xml ../test-data/spsm/target.xml
./match-manager.sh online ../test-data/spsm/source.xml ../test-data/spsm/target.xml ../test-data/spsm/result-spsm.txt -config=../conf/s-match-spsm.properties -property=ContextLoader=it.unitn.disi.smatch.loaders.context.SimpleXMLContextLoader
