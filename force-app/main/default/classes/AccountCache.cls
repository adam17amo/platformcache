public class AccountCache implements Cache.CacheBuilder {
    public Object doLoad(String var) {
        System.debug('Running myAccounts');
        List<Account> accounts =
            (List<Account>) [SELECT ID,
                            AnnualRevenue,
                            Name,
                            Region__c
                            FROM Account
                            ORDER BY
                            AnnualRevenue DESC
                            NULLS LAST
                            LIMIT 10];
        return accounts;
    }
}