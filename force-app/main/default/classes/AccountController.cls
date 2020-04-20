public class AccountController {
    public Long querySeconds {get; set;}
    public Long cacheSeconds {get; set;}
    public Boolean useCache		{get; set;}

    public List<Account> getTopTenAccounts(){
        Long startMillis = System.now().getTime();
        List<Account> accounts = [SELECT Name, Region__c, BillingAddress, Description, 
                      Industry, Type, Opportunity_Count__c, AnnualRevenue 
                      FROM Account ORDER BY AnnualRevenue DESC NULLS LAST LIMIT 10];
        Long endMillis = System.now().getTime();
        Long diff = endMillis - startMillis;
        System.debug('Diff is ' + diff);
        querySeconds = diff;
        // Add to Cache
        Cache.Org.put('local.AcctPartition.TopAccounts', accounts);
            
		return accounts;
    }
    
    public List<Account> getTopTenAccountsCache(){
        Long startMillisCache = System.now().getTime();
        // Get the cache partition
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.AcctPartition');
        // Get the data and cast it to the right datatype
        List<Account> accountsCache = (List<Account>)orgPart.get('TopAccounts');
        Long endMillisCache = System.now().getTime();
        Long diffCache = endMillisCache - startMillisCache;
        System.debug('Diff cache is ' + diffCache);
        cacheSeconds = diffCache;
        if(accountsCache != null) {
            return accountsCache;
        }
        
        return getTopTenAccounts();
    }
}