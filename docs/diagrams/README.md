# Manufacturing Streaming Demo - Architecture Diagrams

This directory contains visual documentation of the complete data architecture for the Manufacturing Streaming Demo showcasing Snowflake's real-time capabilities.

## Diagrams Overview

### 📊 [Physical Data Model](./physical-data-model.mmd)
**Purpose**: Complete database schema documentation showing all tables, columns, data types, and relationships.

**What it shows**:
- **Raw Data Layer**: 3 JSON ingestion tables with Snowpipe auto-ingestion
- **Star Schema Layer**: 4 dimension tables + 3 fact tables with full foreign key relationships
- **Aggregation Layer**: 5 KPI tables with time-windowed aggregations
- **Data Types**: Snowflake-specific types (VARIANT, TIMESTAMP_NTZ, etc.)
- **Primary/Foreign Keys**: Complete referential integrity mapping

**Use Cases**:
- Database development and maintenance
- Data modeling reference
- ETL/ELT development
- Performance optimization planning

---

### 🔄 [Data Flow Architecture](./data-flow-architecture.mmd)
**Purpose**: End-to-end data pipeline visualization from generation to consumption.

**What it shows**:
- **Data Generation**: Python containerized data generators
- **Ingestion**: File staging and Snowpipe auto-ingestion
- **Stream Processing**: Change data capture and transformation procedures
- **Star Schema**: Dimensional modeling for analytics
- **Aggregations**: Real-time KPI calculation with scheduled tasks
- **Timing**: Processing frequencies from 30 seconds to 15 minutes

**Use Cases**:
- Understanding data flow and dependencies
- Troubleshooting streaming issues
- Performance monitoring and optimization
- System documentation for operations teams

## How to View the Diagrams

### GitHub (Recommended)
GitHub natively renders Mermaid diagrams. Simply click on the `.mmd` files to view them with full syntax highlighting and interactivity.

### Local Development
1. **VS Code**: Install the "Mermaid Preview" extension
2. **IntelliJ/PyCharm**: Install the "Mermaid" plugin
3. **Command Line**: Use `mermaid-cli` to generate images:
   ```bash
   npm install -g @mermaid-js/mermaid-cli
   mmdc -i physical-data-model.mmd -o physical-data-model.png
   ```

### Online Tools
- [Mermaid Live Editor](https://mermaid.live/): Copy/paste diagram content for editing
- [GitHub Gist](https://gist.github.com/): Create public gists with `.mmd` extension

## Manufacturing Domain Context

These diagrams specifically model a **manufacturing environment** with:

### Equipment Types
- Hydraulic presses, assembly robots, conveyors
- Spot welders, CNC drills, quality scanners

### Data Streams
- **Sensor Data**: Temperature, pressure, vibration, speed, power consumption
- **Production Data**: Units produced, cycle times, downtime, operator information
- **Quality Data**: Test results, defect classification, inspector records

### Key Performance Indicators (KPIs)
- **Equipment Performance**: OEE, availability, efficiency, predictive maintenance
- **Production Metrics**: Throughput, first-pass yield, downtime analysis
- **Quality Control**: Defect rates, statistical process control, compliance tracking

### Real-time Capabilities
- **Sub-minute ingestion** via Snowpipe
- **1-minute transformations** via Streams
- **30-second dashboard updates** via scheduled tasks
- **Predictive analytics** with failure probability scoring

## Maintenance Notes

When updating the database schema:
1. Update the corresponding diagram files
2. Regenerate any exported images if used in presentations
3. Update this README if new diagrams are added
4. Validate Mermaid syntax using online tools before committing

## Related Documentation
- [Main README](../../README.md): Complete setup and usage guide
- [SQL Scripts](../../sql/): Database schema implementation
- [Data Generator](../../data-generator/): Synthetic data creation
- [Java Streaming](../../java-streaming/): Stream processing application 