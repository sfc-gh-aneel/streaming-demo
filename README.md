# Manufacturing Real-Time Streaming Demo for Snowflake

A comprehensive end-to-end demonstration of real-time data streaming in Snowflake using Snowpark Container Services, showcasing a manufacturing industry use case with synthetic sensor data, production metrics, and quality control data.

## 🏗️ Architecture Overview
<svg aria-roledescription="flowchart-v2" role="graphics-document document" viewBox="-8 -8 1592.16796875 1262" style="max-width: 1592.16796875px;" xmlns="http://www.w3.org/2000/svg" width="100%" id="mermaid-svg-1752690790523-9anmagz5j"><style>#mermaid-svg-1752690790523-9anmagz5j{font-family:"trebuchet ms",verdana,arial,sans-serif;font-size:16px;fill:rgba(204, 204, 204, 0.87);}#mermaid-svg-1752690790523-9anmagz5j .error-icon{fill:#bf616a;}#mermaid-svg-1752690790523-9anmagz5j .error-text{fill:#bf616a;stroke:#bf616a;}#mermaid-svg-1752690790523-9anmagz5j .edge-thickness-normal{stroke-width:2px;}#mermaid-svg-1752690790523-9anmagz5j .edge-thickness-thick{stroke-width:3.5px;}#mermaid-svg-1752690790523-9anmagz5j .edge-pattern-solid{stroke-dasharray:0;}#mermaid-svg-1752690790523-9anmagz5j .edge-pattern-dashed{stroke-dasharray:3;}#mermaid-svg-1752690790523-9anmagz5j .edge-pattern-dotted{stroke-dasharray:2;}#mermaid-svg-1752690790523-9anmagz5j .marker{fill:rgba(204, 204, 204, 0.87);stroke:rgba(204, 204, 204, 0.87);}#mermaid-svg-1752690790523-9anmagz5j .marker.cross{stroke:rgba(204, 204, 204, 0.87);}#mermaid-svg-1752690790523-9anmagz5j svg{font-family:"trebuchet ms",verdana,arial,sans-serif;font-size:16px;}#mermaid-svg-1752690790523-9anmagz5j .label{font-family:"trebuchet ms",verdana,arial,sans-serif;color:rgba(204, 204, 204, 0.87);}#mermaid-svg-1752690790523-9anmagz5j .cluster-label text{fill:#ffffff;}#mermaid-svg-1752690790523-9anmagz5j .cluster-label span,#mermaid-svg-1752690790523-9anmagz5j p{color:#ffffff;}#mermaid-svg-1752690790523-9anmagz5j .label text,#mermaid-svg-1752690790523-9anmagz5j span,#mermaid-svg-1752690790523-9anmagz5j p{fill:rgba(204, 204, 204, 0.87);color:rgba(204, 204, 204, 0.87);}#mermaid-svg-1752690790523-9anmagz5j .node rect,#mermaid-svg-1752690790523-9anmagz5j .node circle,#mermaid-svg-1752690790523-9anmagz5j .node ellipse,#mermaid-svg-1752690790523-9anmagz5j .node polygon,#mermaid-svg-1752690790523-9anmagz5j .node path{fill:#1a1a1a;stroke:#2a2a2a;stroke-width:1px;}#mermaid-svg-1752690790523-9anmagz5j .flowchart-label text{text-anchor:middle;}#mermaid-svg-1752690790523-9anmagz5j .node .label{text-align:center;}#mermaid-svg-1752690790523-9anmagz5j .node.clickable{cursor:pointer;}#mermaid-svg-1752690790523-9anmagz5j .arrowheadPath{fill:#e5e5e5;}#mermaid-svg-1752690790523-9anmagz5j .edgePath .path{stroke:rgba(204, 204, 204, 0.87);stroke-width:2.0px;}#mermaid-svg-1752690790523-9anmagz5j .flowchart-link{stroke:rgba(204, 204, 204, 0.87);fill:none;}#mermaid-svg-1752690790523-9anmagz5j .edgeLabel{background-color:#1a1a1a99;text-align:center;}#mermaid-svg-1752690790523-9anmagz5j .edgeLabel rect{opacity:0.5;background-color:#1a1a1a99;fill:#1a1a1a99;}#mermaid-svg-1752690790523-9anmagz5j .labelBkg{background-color:rgba(26, 26, 26, 0.5);}#mermaid-svg-1752690790523-9anmagz5j .cluster rect{fill:rgba(64, 64, 64, 0.47);stroke:#30373a;stroke-width:1px;}#mermaid-svg-1752690790523-9anmagz5j .cluster text{fill:#ffffff;}#mermaid-svg-1752690790523-9anmagz5j .cluster span,#mermaid-svg-1752690790523-9anmagz5j p{color:#ffffff;}#mermaid-svg-1752690790523-9anmagz5j div.mermaidTooltip{position:absolute;text-align:center;max-width:200px;padding:2px;font-family:"trebuchet ms",verdana,arial,sans-serif;font-size:12px;background:#88c0d0;border:1px solid #30373a;border-radius:2px;pointer-events:none;z-index:100;}#mermaid-svg-1752690790523-9anmagz5j .flowchartTitleText{text-anchor:middle;font-size:18px;fill:rgba(204, 204, 204, 0.87);}#mermaid-svg-1752690790523-9anmagz5j :root{--mermaid-font-family:"trebuchet ms",verdana,arial,sans-serif;}</style><g><marker orient="auto" markerHeight="12" markerWidth="12" markerUnits="userSpaceOnUse" refY="5" refX="6" viewBox="0 0 10 10" class="marker flowchart" id="mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd"><path style="stroke-width: 1; stroke-dasharray: 1, 0;" class="arrowMarkerPath" d="M 0 0 L 10 5 L 0 10 z"/></marker><marker orient="auto" markerHeight="12" markerWidth="12" markerUnits="userSpaceOnUse" refY="5" refX="4.5" viewBox="0 0 10 10" class="marker flowchart" id="mermaid-svg-1752690790523-9anmagz5j_flowchart-pointStart"><path style="stroke-width: 1; stroke-dasharray: 1, 0;" class="arrowMarkerPath" d="M 0 5 L 10 10 L 10 0 z"/></marker><marker orient="auto" markerHeight="11" markerWidth="11" markerUnits="userSpaceOnUse" refY="5" refX="11" viewBox="0 0 10 10" class="marker flowchart" id="mermaid-svg-1752690790523-9anmagz5j_flowchart-circleEnd"><circle style="stroke-width: 1; stroke-dasharray: 1, 0;" class="arrowMarkerPath" r="5" cy="5" cx="5"/></marker><marker orient="auto" markerHeight="11" markerWidth="11" markerUnits="userSpaceOnUse" refY="5" refX="-1" viewBox="0 0 10 10" class="marker flowchart" id="mermaid-svg-1752690790523-9anmagz5j_flowchart-circleStart"><circle style="stroke-width: 1; stroke-dasharray: 1, 0;" class="arrowMarkerPath" r="5" cy="5" cx="5"/></marker><marker orient="auto" markerHeight="11" markerWidth="11" markerUnits="userSpaceOnUse" refY="5.2" refX="12" viewBox="0 0 11 11" class="marker cross flowchart" id="mermaid-svg-1752690790523-9anmagz5j_flowchart-crossEnd"><path style="stroke-width: 2; stroke-dasharray: 1, 0;" class="arrowMarkerPath" d="M 1,1 l 9,9 M 10,1 l -9,9"/></marker><marker orient="auto" markerHeight="11" markerWidth="11" markerUnits="userSpaceOnUse" refY="5.2" refX="-1" viewBox="0 0 11 11" class="marker cross flowchart" id="mermaid-svg-1752690790523-9anmagz5j_flowchart-crossStart"><path style="stroke-width: 2; stroke-dasharray: 1, 0;" class="arrowMarkerPath" d="M 1,1 l 9,9 M 10,1 l -9,9"/></marker><g class="root"><g class="clusters"><g id="subGraph6" class="cluster default flowchart-label"><rect height="103" width="1119.015625" y="1143" x="399.59375" ry="0" rx="0" style=""/><g transform="translate(890.7421875, 1143)" class="cluster-label"><foreignObject height="19" width="136.71875"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">Consumption Layer</span></div></foreignObject></g></g><g id="subGraph5" class="cluster default flowchart-label"><rect height="103" width="1125.078125" y="990" x="451.08984375" ry="0" rx="0" style=""/><g transform="translate(948.98828125, 990)" class="cluster-label"><foreignObject height="19" width="129.28125"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">Aggregation Layer</span></div></foreignObject></g></g><g id="subGraph4" class="cluster default flowchart-label"><rect height="103" width="1548.41796875" y="837" x="0" ry="0" rx="0" style=""/><g transform="translate(664.138671875, 837)" class="cluster-label"><foreignObject height="19" width="220.140625"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">Star Schema (Analytical Layer)</span></div></foreignObject></g></g><g id="subGraph3" class="cluster default flowchart-label"><rect height="206" width="1391.21484375" y="581" x="73.9140625" ry="0" rx="0" style=""/><g transform="translate(704.818359375, 581)" class="cluster-label"><foreignObject height="19" width="129.40625"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">Stream Processing</span></div></foreignObject></g></g><g id="subGraph2" class="cluster default flowchart-label"><rect height="103" width="680.4375" y="428" x="312.00390625" ry="0" rx="0" style=""/><g transform="translate(596.43359375, 428)" class="cluster-label"><foreignObject height="19" width="111.578125"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">Raw Data Layer</span></div></foreignObject></g></g><g id="subGraph1" class="cluster default flowchart-label"><rect height="206" width="510.7890625" y="172" x="387.04296875" ry="0" rx="0" style=""/><g transform="translate(588.0234375, 172)" class="cluster-label"><foreignObject height="19" width="108.828125"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">Ingestion Layer</span></div></foreignObject></g></g><g id="subGraph0" class="cluster default flowchart-label"><rect height="122" width="302.53125" y="0" x="501.38671875" ry="0" rx="0" style=""/><g transform="translate(571.73828125, 0)" class="cluster-label"><foreignObject height="19" width="161.828125"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">Data Generation Layer</span></div></foreignObject></g></g></g><g class="edgePaths"><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-A LE-C" id="L-A-C-0" d="M652.652,97L652.652,101.167C652.652,105.333,652.652,113.667,652.652,122C652.652,130.333,652.652,138.667,652.652,147C652.652,155.333,652.652,163.667,652.652,171.117C652.652,178.567,652.652,185.133,652.652,188.417L652.652,191.7"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-C LE-B" id="L-C-B-0" d="M652.652,250L652.652,254.167C652.652,258.333,652.652,266.667,652.652,274.117C652.652,281.567,652.652,288.133,652.652,291.417L652.652,294.7"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-B LE-D" id="L-B-D-0" d="M604.27,337.544L574.732,344.287C545.194,351.03,486.118,364.515,456.581,375.424C427.043,386.333,427.043,394.667,427.043,403C427.043,411.333,427.043,419.667,427.043,427.117C427.043,434.567,427.043,441.133,427.043,444.417L427.043,447.7"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-B LE-E" id="L-B-E-0" d="M652.652,353L652.652,357.167C652.652,361.333,652.652,369.667,652.652,378C652.652,386.333,652.652,394.667,652.652,403C652.652,411.333,652.652,419.667,652.652,427.117C652.652,434.567,652.652,441.133,652.652,444.417L652.652,447.7"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-B LE-F" id="L-B-F-0" d="M701.035,337.565L730.501,344.305C759.967,351.044,818.9,364.522,848.366,375.428C877.832,386.333,877.832,394.667,877.832,403C877.832,411.333,877.832,419.667,877.832,427.117C877.832,434.567,877.832,441.133,877.832,444.417L877.832,447.7"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-D LE-G" id="L-D-G-0" d="M427.043,506L427.043,510.167C427.043,514.333,427.043,522.667,427.043,531C427.043,539.333,427.043,547.667,427.043,556C427.043,564.333,427.043,572.667,448.873,581.821C470.702,590.976,514.361,600.951,536.191,605.939L558.021,610.927"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-E LE-G" id="L-E-G-0" d="M652.652,506L652.652,510.167C652.652,514.333,652.652,522.667,652.652,531C652.652,539.333,652.652,547.667,652.652,556C652.652,564.333,652.652,572.667,652.639,580.117C652.625,587.567,652.598,594.133,652.584,597.417L652.57,600.7"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-F LE-G" id="L-F-G-0" d="M877.832,506L877.832,510.167C877.832,514.333,877.832,522.667,877.832,531C877.832,539.333,877.832,547.667,877.832,556C877.832,564.333,877.832,572.667,856.002,581.821C834.173,590.976,790.514,600.951,768.684,605.939L746.854,610.927"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-G LE-H" id="L-G-H-0" d="M652.438,659L652.438,663.167C652.438,667.333,652.438,675.667,652.438,683.117C652.438,690.567,652.438,697.133,652.438,700.417L652.438,703.7"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-H LE-I" id="L-H-I-0" d="M555.711,744.75L482.078,751.792C408.445,758.833,261.18,772.917,187.547,784.125C113.914,795.333,113.914,803.667,113.914,812C113.914,820.333,113.914,828.667,113.914,836.117C113.914,843.567,113.914,850.133,113.914,853.417L113.914,856.7"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-H LE-J" id="L-H-J-0" d="M555.711,751.141L518.751,757.118C481.792,763.094,407.872,775.047,370.913,785.19C333.953,795.333,333.953,803.667,333.953,812C333.953,820.333,333.953,828.667,333.953,836.117C333.953,843.567,333.953,850.133,333.953,853.417L333.953,856.7"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-H LE-K" id="L-H-K-0" d="M597.03,762L588.318,766.167C579.606,770.333,562.182,778.667,553.47,787C544.758,795.333,544.758,803.667,544.758,812C544.758,820.333,544.758,828.667,544.758,836.117C544.758,843.567,544.758,850.133,544.758,853.417L544.758,856.7"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-H LE-L" id="L-H-L-0" d="M707.845,762L716.557,766.167C725.269,770.333,742.693,778.667,751.405,787C760.117,795.333,760.117,803.667,760.117,812C760.117,820.333,760.117,828.667,760.117,836.117C760.117,843.567,760.117,850.133,760.117,853.417L760.117,856.7"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-H LE-M" id="L-H-M-0" d="M749.164,744.753L822.768,751.794C896.371,758.835,1043.578,772.918,1117.182,784.126C1190.785,795.333,1190.785,803.667,1190.785,812C1190.785,820.333,1190.785,828.667,1190.785,836.117C1190.785,843.567,1190.785,850.133,1190.785,853.417L1190.785,856.7"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-H LE-N" id="L-H-N-0" d="M749.164,741.784L865.158,749.32C981.152,756.856,1213.141,771.928,1329.135,783.631C1445.129,795.333,1445.129,803.667,1445.129,812C1445.129,820.333,1445.129,828.667,1445.129,836.117C1445.129,843.567,1445.129,850.133,1445.129,853.417L1445.129,856.7"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-L LE-O" id="L-L-O-0" d="M683.397,915L671.334,919.167C659.271,923.333,635.145,931.667,623.082,940C611.02,948.333,611.02,956.667,611.02,965C611.02,973.333,611.02,981.667,611.02,989.117C611.02,996.567,611.02,1003.133,611.02,1006.417L611.02,1009.7"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-M LE-P" id="L-M-P-0" d="M1190.785,915L1190.785,919.167C1190.785,923.333,1190.785,931.667,1190.785,940C1190.785,948.333,1190.785,956.667,1190.785,965C1190.785,973.333,1190.785,981.667,1190.785,989.117C1190.785,996.567,1190.785,1003.133,1190.785,1006.417L1190.785,1009.7"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-N LE-Q" id="L-N-Q-0" d="M1445.129,915L1445.129,919.167C1445.129,923.333,1445.129,931.667,1445.129,940C1445.129,948.333,1445.129,956.667,1445.129,965C1445.129,973.333,1445.129,981.667,1445.129,989.117C1445.129,996.567,1445.129,1003.133,1445.129,1006.417L1445.129,1009.7"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-L LE-R" id="L-L-R-0" d="M836.837,915L848.9,919.167C860.963,923.333,885.089,931.667,897.152,940C909.215,948.333,909.215,956.667,909.215,965C909.215,973.333,909.215,981.667,909.215,989.117C909.215,996.567,909.215,1003.133,909.215,1006.417L909.215,1009.7"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-O LE-S" id="L-O-S-0" d="M605.874,1068L605.065,1072.167C604.256,1076.333,602.638,1084.667,601.829,1093C601.02,1101.333,601.02,1109.667,601.02,1118C601.02,1126.333,601.02,1134.667,635.427,1144.552C669.834,1154.436,738.649,1165.873,773.056,1171.591L807.463,1177.309"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-P LE-S" id="L-P-S-0" d="M1123.488,1068L1112.907,1072.167C1102.325,1076.333,1081.163,1084.667,1070.581,1093C1060,1101.333,1060,1109.667,1060,1118C1060,1126.333,1060,1134.667,1048.772,1142.712C1037.544,1150.757,1015.088,1158.513,1003.86,1162.391L992.632,1166.27"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-Q LE-S" id="L-Q-S-0" d="M1384.837,1068L1375.357,1072.167C1365.877,1076.333,1346.917,1084.667,1337.437,1093C1327.957,1101.333,1327.957,1109.667,1327.957,1118C1327.957,1126.333,1327.957,1134.667,1275.693,1145.287C1223.429,1155.908,1118.901,1168.815,1066.637,1175.269L1014.373,1181.723"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-R LE-T" id="L-R-T-0" d="M909.215,1068L909.215,1072.167C909.215,1076.333,909.215,1084.667,909.215,1093C909.215,1101.333,909.215,1109.667,909.215,1118C909.215,1126.333,909.215,1134.667,880.367,1144.375C851.519,1154.082,793.823,1165.165,764.975,1170.706L736.127,1176.247"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-O LE-U" id="L-O-U-0" d="M682.594,1068L693.848,1072.167C705.102,1076.333,727.609,1084.667,738.863,1093C750.117,1101.333,750.117,1109.667,750.117,1118C750.117,1126.333,750.117,1134.667,806.756,1145.827C863.395,1156.988,976.673,1170.976,1033.312,1177.97L1089.951,1184.964"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-P LE-U" id="L-P-U-0" d="M1251.077,1068L1260.557,1072.167C1270.037,1076.333,1288.997,1084.667,1298.477,1093C1307.957,1101.333,1307.957,1109.667,1307.957,1118C1307.957,1126.333,1307.957,1134.667,1297.316,1142.726C1286.675,1150.785,1265.393,1158.57,1254.751,1162.463L1244.11,1166.356"/><path marker-end="url(#mermaid-svg-1752690790523-9anmagz5j_flowchart-pointEnd)" style="fill:none;" class="edge-thickness-normal edge-pattern-solid flowchart-link LS-Q LE-U" id="L-Q-U-0" d="M1450.275,1068L1451.084,1072.167C1451.893,1076.333,1453.511,1084.667,1454.32,1093C1455.129,1101.333,1455.129,1109.667,1455.129,1118C1455.129,1126.333,1455.129,1134.667,1419.999,1145.116C1384.869,1155.566,1314.61,1168.131,1279.48,1174.414L1244.35,1180.697"/></g><g class="edgeLabels"><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g><g class="edgeLabel"><g transform="translate(0, 0)" class="label"><foreignObject height="0" width="0"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignObject></g></g></g><g class="nodes"><g transform="translate(910.90234375, 1194.5)" id="flowchart-S-443" class="node default default flowchart-label"><rect height="53" width="196.421875" y="-26.5" x="-98.2109375" ry="0" rx="0" style="fill:#e8f5e8;" class="basic label-container"/><g transform="translate(-90.7109375, -19)" style="" class="label"><rect/><foreignObject height="38" width="181.421875"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">Manufacturing Dashboard<br />(Real-time views)</span></div></foreignObject></g></g><g transform="translate(641.1015625, 1194.5)" id="flowchart-T-444" class="node default default flowchart-label"><rect height="53" width="179.640625" y="-26.5" x="-89.8203125" ry="0" rx="0" style="" class="basic label-container"/><g transform="translate(-82.3203125, -19)" style="" class="label"><rect/><foreignObject height="38" width="164.640625"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">Alerts &amp; Notifications<br />(Threshold monitoring)</span></div></foreignObject></g></g><g transform="translate(1167.171875, 1194.5)" id="flowchart-U-445" class="node default default flowchart-label"><rect height="53" width="143.921875" y="-26.5" x="-71.9609375" ry="0" rx="0" style="" class="basic label-container"/><g transform="translate(-64.4609375, -19)" style="" class="label"><rect/><foreignObject height="38" width="128.921875"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">Historical Analysis<br />(Trend reporting)</span></div></foreignObject></g></g><g transform="translate(611.01953125, 1041.5)" id="flowchart-O-439" class="node default default flowchart-label"><rect height="53" width="249.859375" y="-26.5" x="-124.9296875" ry="0" rx="0" style="" class="basic label-container"/><g transform="translate(-117.4296875, -19)" style="" class="label"><rect/><foreignObject height="38" width="234.859375"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">AGG_EQUIPMENT_PERFORMANCE<br />(Real-time KPIs)</span></div></foreignObject></g></g><g transform="translate(1190.78515625, 1041.5)" id="flowchart-P-440" class="node default default flowchart-label"><rect height="53" width="216.609375" y="-26.5" x="-108.3046875" ry="0" rx="0" style="" class="basic label-container"/><g transform="translate(-100.8046875, -19)" style="" class="label"><rect/><foreignObject height="38" width="201.609375"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">AGG_PRODUCTION_METRICS<br />(Throughput &amp; efficiency)</span></div></foreignObject></g></g><g transform="translate(1445.12890625, 1041.5)" id="flowchart-Q-441" class="node default default flowchart-label"><rect height="53" width="192.078125" y="-26.5" x="-96.0390625" ry="0" rx="0" style="" class="basic label-container"/><g transform="translate(-88.5390625, -19)" style="" class="label"><rect/><foreignObject height="38" width="177.078125"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">AGG_QUALITY_SUMMARY<br />(Quality trends)</span></div></foreignObject></g></g><g transform="translate(909.21484375, 1041.5)" id="flowchart-R-442" class="node default default flowchart-label"><rect height="53" width="246.53125" y="-26.5" x="-123.265625" ry="0" rx="0" style="" class="basic label-container"/><g transform="translate(-115.765625, -19)" style="" class="label"><rect/><foreignObject height="38" width="231.53125"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">AGG_PREDICTIVE_MAINTENANCE<br />(Alert indicators)</span></div></foreignObject></g></g><g transform="translate(113.9140625, 888.5)" id="flowchart-I-433" class="node default default flowchart-label"><rect height="53" width="157.828125" y="-26.5" x="-78.9140625" ry="0" rx="0" style="" class="basic label-container"/><g transform="translate(-71.4140625, -19)" style="" class="label"><rect/><foreignObject height="38" width="142.828125"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">DIM_EQUIPMENT<br />(Equipment master)</span></div></foreignObject></g></g><g transform="translate(333.953125, 888.5)" id="flowchart-J-434" class="node default default flowchart-label"><rect height="53" width="182.25" y="-26.5" x="-91.125" ry="0" rx="0" style="" class="basic label-container"/><g transform="translate(-83.625, -19)" style="" class="label"><rect/><foreignObject height="38" width="167.25"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">DIM_PRODUCTION_LINE<br />(Line configuration)</span></div></foreignObject></g></g><g transform="translate(544.7578125, 888.5)" id="flowchart-K-435" class="node default default flowchart-label"><rect height="53" width="139.359375" y="-26.5" x="-69.6796875" ry="0" rx="0" style="" class="basic label-container"/><g transform="translate(-62.1796875, -19)" style="" class="label"><rect/><foreignObject height="38" width="124.359375"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">DIM_TIME<br />(Time dimension)</span></div></foreignObject></g></g><g transform="translate(760.1171875, 888.5)" id="flowchart-L-436" class="node default default flowchart-label"><rect height="53" width="191.359375" y="-26.5" x="-95.6796875" ry="0" rx="0" style="" class="basic label-container"/><g transform="translate(-88.1796875, -19)" style="" class="label"><rect/><foreignObject height="38" width="176.359375"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">FACT_SENSOR_READINGS<br />(Sensor measurements)</span></div></foreignObject></g></g><g transform="translate(1190.78515625, 888.5)" id="flowchart-M-437" class="node default default flowchart-label"><rect height="53" width="155.21875" y="-26.5" x="-77.609375" ry="0" rx="0" style="" class="basic label-container"/><g transform="translate(-70.109375, -19)" style="" class="label"><rect/><foreignObject height="38" width="140.21875"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">FACT_PRODUCTION<br />(Production events)</span></div></foreignObject></g></g><g transform="translate(1445.12890625, 888.5)" id="flowchart-N-438" class="node default default flowchart-label"><rect height="53" width="136.578125" y="-26.5" x="-68.2890625" ry="0" rx="0" style="" class="basic label-container"/><g transform="translate(-60.7890625, -19)" style="" class="label"><rect/><foreignObject height="38" width="121.578125"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">FACT_QUALITY<br />(Quality metrics)</span></div></foreignObject></g></g><g transform="translate(652.4375, 632.5)" id="flowchart-G-431" class="node default default flowchart-label"><rect height="53" width="178.5" y="-26.5" x="-89.25" ry="0" rx="0" style="fill:#fff3e0;" class="basic label-container"/><g transform="translate(-81.75, -19)" style="" class="label"><rect/><foreignObject height="38" width="163.5"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">Snowflake Streams<br />(Change Data Capture)</span></div></foreignObject></g></g><g transform="translate(652.4375, 735.5)" id="flowchart-H-432" class="node default default flowchart-label"><rect height="53" width="193.453125" y="-26.5" x="-96.7265625" ry="0" rx="0" style="fill:#fff3e0;" class="basic label-container"/><g transform="translate(-89.2265625, -19)" style="" class="label"><rect/><foreignObject height="38" width="178.453125"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">Snowflake Tasks<br />(Low-latency processing)</span></div></foreignObject></g></g><g transform="translate(427.04296875, 479.5)" id="flowchart-D-428" class="node default default flowchart-label"><rect height="53" width="160.078125" y="-26.5" x="-80.0390625" ry="0" rx="0" style="" class="basic label-container"/><g transform="translate(-72.5390625, -19)" style="" class="label"><rect/><foreignObject height="38" width="145.078125"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">SENSOR_DATA_RAW<br />(Equipment sensors)</span></div></foreignObject></g></g><g transform="translate(652.65234375, 479.5)" id="flowchart-E-429" class="node default default flowchart-label"><rect height="53" width="191.140625" y="-26.5" x="-95.5703125" ry="0" rx="0" style="" class="basic label-container"/><g transform="translate(-88.0703125, -19)" style="" class="label"><rect/><foreignObject height="38" width="176.140625"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">PRODUCTION_DATA_RAW<br />(Production metrics)</span></div></foreignObject></g></g><g transform="translate(877.83203125, 479.5)" id="flowchart-F-430" class="node default default flowchart-label"><rect height="53" width="159.21875" y="-26.5" x="-79.609375" ry="0" rx="0" style="" class="basic label-container"/><g transform="translate(-72.109375, -19)" style="" class="label"><rect/><foreignObject height="38" width="144.21875"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">QUALITY_DATA_RAW<br />(Quality control)</span></div></foreignObject></g></g><g transform="translate(652.65234375, 326.5)" id="flowchart-B-426" class="node default default flowchart-label"><rect height="53" width="96.765625" y="-26.5" x="-48.3828125" ry="0" rx="0" style="fill:#f3e5f5;" class="basic label-container"/><g transform="translate(-40.8828125, -19)" style="" class="label"><rect/><foreignObject height="38" width="81.765625"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">Snowpipe<br />Auto-Ingest</span></div></foreignObject></g></g><g transform="translate(652.65234375, 223.5)" id="flowchart-C-427" class="node default default flowchart-label"><rect height="53" width="153.78125" y="-26.5" x="-76.890625" ry="0" rx="0" style="" class="basic label-container"/><g transform="translate(-69.390625, -19)" style="" class="label"><rect/><foreignObject height="38" width="138.78125"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">Internal Stage<br />(Compressed JSON)</span></div></foreignObject></g></g><g transform="translate(652.65234375, 61)" id="flowchart-A-425" class="node default default flowchart-label"><rect height="72" width="232.53125" y="-36" x="-116.265625" ry="0" rx="0" style="fill:#e1f5fe;" class="basic label-container"/><g transform="translate(-108.765625, -28.5)" style="" class="label"><rect/><foreignObject height="57" width="217.53125"><div style="display: inline-block; white-space: nowrap;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel">Snowpark Container Service<br />Manufacturing Data Generator<br />(Python + Java SDK)</span></div></foreignObject></g></g></g></g></g></svg>
This demo implements a complete real-time data pipeline with the following components:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Data          │    │   Java           │    │   Raw Data      │
│   Generator     │───▶│   Streaming      │───▶│   Tables        │
│   (Python)      │    │   (Snowpipe)     │    │   (JSON)        │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                        │
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Aggregation   │◀───│   Star Schema    │◀───│   Streams &     │
│   Layer (KPIs)  │    │   (Analytics)    │    │   Transforms    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Architecture Components

1. **Data Generation Layer**
   - Snowpark Container Service running Python application
   - Generates realistic manufacturing sensor, production, and quality data
   - Configurable equipment, production lines, and products

2. **Ingestion Layer**
   - Java streaming application using Snowflake SDK
   - Continuous data upload via Snowpipe
   - Compressed JSON files with automatic ingestion

3. **Raw Data Layer**
   - JSON-based tables for sensor, production, and quality data
   - Optimized for high-volume ingestion
   - Clustering for query performance

4. **Stream Processing**
   - Snowflake Streams for change data capture
   - Low-latency transformation tasks (1-minute intervals)
   - Automatic processing with conditional execution

5. **Star Schema (Analytics)**
   - Dimension tables: Equipment, Production Lines, Products, Time
   - Fact tables: Sensor Readings, Production Events, Quality Tests
   - Optimized for analytical queries

6. **Aggregation Layer**
   - Pre-calculated KPIs and metrics
   - Real-time dashboard data
   - Equipment performance indicators
   - Predictive maintenance alerts

## 🚀 Quick Start

### Prerequisites

- Docker
- Java 11+
- Maven 3.6+
- Python 3.8+
- Snowflake account with appropriate privileges

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd streaming-demo
   ```

2. **Run the setup script**
   ```bash
   ./scripts/setup_demo.sh -a <SNOWFLAKE_ACCOUNT> -u <SNOWFLAKE_USER> -p <SNOWFLAKE_PASSWORD>
   ```

3. **Access the streaming data**
   - Navigate to your Snowflake console
   - Database: `MANUFACTURING_DEMO`
   - Schemas: `RAW_DATA`, `ANALYTICS`, `AGGREGATION`

### Alternative Setup (Step by Step)

If you prefer manual setup or need to customize the installation:

```bash
# 1. Set environment variables
export SNOWFLAKE_ACCOUNT=your_account
export SNOWFLAKE_USER=your_user
export SNOWFLAKE_PASSWORD=your_password

# 2. Setup database and schemas
python3 scripts/execute_sql.py --account $SNOWFLAKE_ACCOUNT --user $SNOWFLAKE_USER --password $SNOWFLAKE_PASSWORD --file sql/01_database_setup.sql
python3 scripts/execute_sql.py --account $SNOWFLAKE_ACCOUNT --user $SNOWFLAKE_USER --password $SNOWFLAKE_PASSWORD --file sql/02_raw_tables.sql
python3 scripts/execute_sql.py --account $SNOWFLAKE_ACCOUNT --user $SNOWFLAKE_USER --password $SNOWFLAKE_PASSWORD --file sql/03_star_schema.sql
python3 scripts/execute_sql.py --account $SNOWFLAKE_ACCOUNT --user $SNOWFLAKE_USER --password $SNOWFLAKE_PASSWORD --file sql/04_aggregation_layer.sql
python3 scripts/execute_sql.py --account $SNOWFLAKE_ACCOUNT --user $SNOWFLAKE_USER --password $SNOWFLAKE_PASSWORD --file sql/05_streams_and_transforms.sql
python3 scripts/execute_sql.py --account $SNOWFLAKE_ACCOUNT --user $SNOWFLAKE_USER --password $SNOWFLAKE_PASSWORD --file sql/06_aggregation_tasks.sql

# 3. Build containers
cd data-generator && docker build -t manufacturing-data-generator:latest .
cd ../java-streaming && mvn clean package && docker build -t manufacturing-streaming:latest .

# 4. Initialize reference data
docker run --rm -e SNOWFLAKE_ACCOUNT=$SNOWFLAKE_ACCOUNT -e SNOWFLAKE_USER=$SNOWFLAKE_USER -e SNOWFLAKE_PASSWORD=$SNOWFLAKE_PASSWORD -e GENERATE_INITIAL_DATA=true manufacturing-data-generator:latest
```

## 📊 Data Schema

### Raw Data Tables

- **`SENSOR_DATA_RAW`**: Equipment sensor readings (temperature, pressure, vibration, speed)
- **`PRODUCTION_DATA_RAW`**: Production events and metrics (units produced, cycle times, downtime)
- **`QUALITY_DATA_RAW`**: Quality control test results and measurements

### Star Schema (Analytics)

#### Dimension Tables
- **`DIM_EQUIPMENT`**: Equipment master data
- **`DIM_PRODUCTION_LINE`**: Production line configuration
- **`DIM_PRODUCT`**: Product catalog
- **`DIM_TIME`**: Time dimension with manufacturing shifts

#### Fact Tables
- **`FACT_SENSOR_READINGS`**: Processed sensor data with alerts
- **`FACT_PRODUCTION`**: Production events and metrics
- **`FACT_QUALITY`**: Quality test results and defect tracking

### Aggregation Layer

- **`AGG_EQUIPMENT_PERFORMANCE`**: Real-time equipment KPIs
- **`AGG_PRODUCTION_METRICS`**: Production line performance
- **`AGG_QUALITY_SUMMARY`**: Quality control summaries
- **`AGG_PREDICTIVE_MAINTENANCE`**: Maintenance alerts and predictions
- **`AGG_REALTIME_DASHBOARD`**: Live dashboard metrics

## 🔧 Configuration

### Data Generator Configuration

Edit `data-generator/config/config.yaml` to customize:

- **Equipment**: Types, specifications, and limits
- **Production Lines**: Capacity, shift patterns, products
- **Data Generation**: Intervals, batch sizes, simulation parameters
- **Quality Control**: Test types, specifications, defect rates

### Java Streaming Configuration

Environment variables for the Java streaming application:

```bash
SNOWFLAKE_ACCOUNT=your_account
SNOWFLAKE_USER=your_user
SNOWFLAKE_PASSWORD=your_password
STREAMING_INTERVAL_SECONDS=30
STREAMING_BATCH_SIZE=1000
METRICS_ENABLED=true
```

## 📈 Monitoring and Metrics

### Real-Time Dashboard Queries

```sql
-- Current equipment status
SELECT * FROM MANUFACTURING_DEMO.AGGREGATION.AGG_REALTIME_DASHBOARD 
ORDER BY snapshot_timestamp DESC LIMIT 1;

-- Equipment performance last hour
SELECT * FROM MANUFACTURING_DEMO.AGGREGATION.AGG_EQUIPMENT_PERFORMANCE 
WHERE time_window_start >= CURRENT_TIMESTAMP() - INTERVAL '1 HOUR'
ORDER BY time_window_start DESC;

-- Production efficiency by line
SELECT 
    line_name,
    AVG(production_efficiency_percent) as avg_efficiency,
    SUM(total_units_produced) as total_units
FROM MANUFACTURING_DEMO.AGGREGATION.AGG_PRODUCTION_METRICS 
WHERE time_window_start >= CURRENT_DATE()
GROUP BY line_name;

-- Quality trends
SELECT 
    product_name,
    AVG(pass_rate_percent) as avg_pass_rate,
    AVG(defect_rate_per_thousand) as avg_defect_rate
FROM MANUFACTURING_DEMO.AGGREGATION.AGG_QUALITY_SUMMARY 
WHERE time_window_start >= CURRENT_DATE()
GROUP BY product_name;
```

### Predictive Maintenance Alerts

```sql
-- Equipment requiring immediate attention
SELECT 
    equipment_name,
    overall_health_score,
    recommended_action,
    maintenance_priority,
    predicted_failure_days
FROM MANUFACTURING_DEMO.AGGREGATION.AGG_PREDICTIVE_MAINTENANCE 
WHERE maintenance_priority IN ('HIGH', 'CRITICAL')
ORDER BY overall_health_score ASC;
```

## 📁 Project Structure

```
streaming-demo/
├── README.md                          # This file
├── sql/                               # Database setup scripts
│   ├── 01_database_setup.sql          # Database and schema creation
│   ├── 02_raw_tables.sql              # Raw data tables and Snowpipes
│   ├── 03_star_schema.sql             # Dimensional model
│   ├── 04_aggregation_layer.sql       # KPI and metrics tables
│   ├── 05_streams_and_transforms.sql  # Real-time transformation logic
│   └── 06_aggregation_tasks.sql       # Aggregation task definitions
├── data-generator/                    # Python data generator
│   ├── Dockerfile                     # Container configuration
│   ├── requirements.txt               # Python dependencies
│   ├── config/config.yaml             # Data generation configuration
│   ├── src/main.py                    # Main application
│   ├── src/config_loader.py           # Configuration management
│   ├── src/data_generators.py         # Data generation logic
│   └── src/snowflake_uploader.py      # Snowflake integration
├── java-streaming/                    # Java streaming application
│   ├── pom.xml                        # Maven configuration
│   └── src/main/java/                 # Java source code
│       └── com/snowflake/demo/streaming/
│           ├── ManufacturingStreamingApp.java
│           ├── config/StreamingConfig.java
│           └── service/               # Service classes
└── scripts/                          # Automation scripts
    ├── setup_demo.sh                 # Main setup script
    └── execute_sql.py                # SQL execution helper
```

## 🛠️ Customization

### Adding New Equipment Types

1. Edit `data-generator/config/config.yaml`
2. Add equipment configuration under `manufacturing.equipment`
3. Update sensor data parameters if needed
4. Restart the data generator

### Custom KPIs and Metrics

1. Modify aggregation procedures in `sql/06_aggregation_tasks.sql`
2. Add new aggregation tables in `sql/04_aggregation_layer.sql`
3. Update transformation logic as needed

### Scaling Configuration

- **Data Volume**: Adjust `generation.batch_size` and `generation.interval_seconds`
- **Processing**: Modify task schedules in transformation and aggregation scripts
- **Storage**: Configure table clustering and retention policies

## 🔍 Troubleshooting

### Common Issues

1. **Connection Errors**
   ```bash
   # Verify Snowflake credentials
   snowsql -a $SNOWFLAKE_ACCOUNT -u $SNOWFLAKE_USER
   ```

2. **Container Build Failures**
   ```bash
   # Check Docker and build dependencies
   docker --version
   java -version
   mvn --version
   ```

3. **Data Not Appearing**
   ```sql
   -- Check pipe status
   SHOW PIPES IN SCHEMA MANUFACTURING_DEMO.RAW_DATA;
   
   -- Check stream status
   SHOW STREAMS IN SCHEMA MANUFACTURING_DEMO.RAW_DATA;
   
   -- Check task status
   SHOW TASKS IN SCHEMA MANUFACTURING_DEMO.UTILITIES;
   ```

### Log Analysis

```bash
# View container logs
docker logs <container_id>

# Check Snowflake task history
SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE database_name = 'MANUFACTURING_DEMO'
ORDER BY scheduled_time DESC;
```

## 🎯 Demo Scenarios

### Real-Time Monitoring
- Monitor equipment performance in real-time
- Track production efficiency across multiple lines
- Identify quality issues as they occur

### Predictive Maintenance
- Analyze sensor trends to predict equipment failures
- Schedule maintenance based on performance degradation
- Optimize maintenance schedules and costs

### Quality Control
- Track defect rates and quality trends
- Identify process improvements
- Correlate quality issues with equipment performance

### Production Optimization
- Analyze throughput and efficiency patterns
- Identify bottlenecks in production lines
- Optimize shift schedules and resource allocation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋 Support

For questions and support:
- Review the troubleshooting section above
- Check Snowflake documentation for specific features
- Open an issue in this repository for bugs or feature requests

---

## 📚 Additional Resources

- [Snowflake Documentation](https://docs.snowflake.com/)
- [Snowpark Container Services](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview)
- [Snowpipe Documentation](https://docs.snowflake.com/en/user-guide/data-load-snowpipe)
- [Manufacturing Analytics Best Practices](https://www.snowflake.com/workloads/manufacturing/)

Happy streaming! 🚀
