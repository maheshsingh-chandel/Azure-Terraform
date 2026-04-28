# Azure Data Lake and Analytics

Deploys Event Hubs with Capture into ADLS Gen2, raw/curated/synapse filesystems, Data Factory, Synapse workspace, a dedicated SQL pool, and Log Analytics.

Production notes:

- Connect Power BI to Synapse or serverless SQL views over ADLS.
- Add Data Factory pipelines for workload-specific raw-to-curated transformation.
- Event Hubs Capture lands immutable Avro files in the raw zone.
