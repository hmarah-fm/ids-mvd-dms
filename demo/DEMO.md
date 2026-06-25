# Demo Setup

The demo has the goal to show the full DMS functionalities working. 
It uses the Adient daa received from the partners and splits in two datasets: 1) External processes and 2) Internal processes.

The datasets can be found in the Teams folder under WP4 and should be included in the demo/dataset_1 folder the one about external processes and the seocnd one on demo/dataset_2 about the internal processes. 

Additionally, the DEMO postman collection runs the registration of these datasets where:
dataset_1 is registered by the connector QNA and dataset_2 is registered by the connector Manufacturing. 

This DEMO setup, uses the demo/demo_dms.json as the properties for the digital thread and should be set in the digital-thread.env:

DMS_PROPERTIES_PATH=demo/demo_dms.json
