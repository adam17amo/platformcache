public class AccountRegionController {
    public Long querySeconds {get; set;}
    public Long cacheSeconds {get; set;}
    public Boolean useCache		{get; set;}

    public List<AccountDetail> getAccountsByRegion(){
        Map<String, Integer> accountsByRegion = new Map<String, Integer>();
        List<Schema.PicklistEntry> regions = Account.Region__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry pe : regions){
            accountsByRegion.put(pe.value, 0);
        }
        Long startMillis = System.now().getTime();
        for(String regionName : accountsByRegion.keySet()){
            Integer count = [SELECT count() FROM Account WHERE Region__c = :regionName];
            accountsByRegion.put(regionName, count);
        }
        Long endMillis = System.now().getTime();
        Long diff = endMillis - startMillis;
        System.debug('Diff is ' + diff);
        querySeconds = diff;
        // Put any data structure into the cache
        Cache.Org.put('local.AcctPartition.RegionAccounts', accountsByRegion);
        return convertMapToDetail(accountsByRegion);
    }
    
    public List<AccountDetail> getAccountsByRegionCache(){
       	Long startMillisCache = System.now().getTime();
        Map<String, Integer> accountsByRegion =
            (Map<String, Integer>)Cache.Org.getPartition('local.AcctPartition').get('RegionAccounts');
        Long endMillisCache = System.now().getTime();
        Long diffCache = endMillisCache - startMillisCache;
        System.debug('Diff cache is ' + diffCache);
        cacheSeconds = diffCache;
        if(accountsByRegion != null) {
            return convertMapToDetail(accountsByRegion);
        }
        
        return getAccountsByRegion();
    }
    
    private List<AccountDetail> convertMapToDetail(Map<String, Integer> mapToConvert){
        List<AccountDetail> details = new List<AccountDetail>();
        for(String name : mapToConvert.keySet()){
            details.add(new AccountDetail(name, mapToConvert.get(name)));
        }
        return details;
    }
    
    public class AccountDetail {
        public String regionName {get;set;}
        public Integer total {get;set;}
        public AccountDetail(String name, Integer count){
            this.regionName = name;
            this.total = count;
        }
    }
}