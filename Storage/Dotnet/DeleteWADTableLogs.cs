//'By using the following materials or sample code you agree to be bound by the license terms below 
//'and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference. 
//'These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you 
//'are located, one of its affiliates) and you. Any materials (other than sample code) we provide to you 
//'are for your internal use only. Any sample code is provided for the purpose of illustration only and is 
//'not intended to be used in a production environment. We grant you a nonexclusive, royalty-free right to 
//'use and modify the sample code and to reproduce and distribute the object code form of the sample code, 
//'provided that you agree: (i) to not use Microsoft’s name, logo, or trademarks to market your software product 
//'in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in 
//'which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors 
//'a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable 
//'limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and 
//'suppliers from and against any third party claims or lawsuits, including attorneys’ fees, that arise or result 
//'from the use or distribution of the sample code."  

//Note: when querying WADLogsTable using LINQ in C#, setting tsc.MergeOptions = MergeOption.NoTracking can help avoid scanning all log entries, improving query performance.

//This code helps delete older entities from WADWindowsEventLogsTable and Linux (LAD) logs while avoiding scanning all log entries, thereby improving query performance.

public static CloudTableQuery<TEntity> GetDiagnosticEntities<TEntity>(
 this TableServiceContext tsc, String tableName,
 DateTime startTime, DateTime endTime,
 String deploymentId = null, String roleName = null, 
 String roleInstanceId = null) where TEntity : WadTableEntity {
 
 const String TickFormat = "D19"; // 19-digit, 0-padded
 String startTimeStr = startTime.Ticks.ToString(TickFormat);
 String endTimeStr = endTime.Ticks.ToString(TickFormat);
 
 String startRoleInstance = AzureDiagnosticsRowKey(deploymentId, roleName, roleInstanceId);
 String endRoleInstance = startRoleInstance.GetNextKey();
 tsc.MergeOptions = MergeOptions.NoTracking; 
 return (from e in tsc.CreateQuery<TEntity>(tableName)
 where (e.PartitionKey.CompareTo(startTimeStr) >= 0 
 && e.PartitionKey.CompareTo(endTimeStr) < 0) 
 && (e.RowKey.CompareTo(startRoleInstance) >= 0
 && e.RowKey.CompareTo(endRoleInstance) < 0)
 select e).AsTableServiceQuery();
 }
 
 private static String AzureDiagnosticsRowKey(String deploymentId = null, String roleName = null, String roleInstanceId = null) {
 var sb = new StringBuilder();
 if (!String.IsNullOrWhiteSpace(deployment)) {
 sb.Append(deployment).Append("___");
 if (!String.IsNullOrWhiteSpace(role)) {
 sb.Append(role).Append("___");
 if (!String.IsNullOrWhiteSpace(roleInstance))
 sb.Append(roleInstance);
 }
 }
 return sb.ToString();
 }
 
 private static String GetNextKey(String @string) {
 var sb = new StringBuilder(@string); 
 sb[sb.Length - 1]++; 
 return sb.ToString();
 }
