public with sharing class AccountsOverAmountApex {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountOverRevenue(Decimal amount) {
        Long startTime = System.now().getTime();
        System.debug('Start time is ' + startTime);
        List<Account> accounts = [SELECT Id, Name, AnnualRevenue, Type FROM Account WHERE Region__c != null ORDER BY AnnualRevenue DESC LIMIT 50000];
        List<Account> topAccounts = new List<Account>();
        for(Account a : accounts) {
            if(a.AnnualRevenue > amount) {
                topAccounts.add(a);
            }
        }
        Long endTime = System.now().getTime();
        System.debug('End time is ' + endTime);
        System.debug('Total is ' + (endTime-startTime));
        return topAccounts;
    }

    @AuraEnabled
    public static void updateOpptyStage(Decimal amount, String stage) {
        for (List<Opportunity> oppts:
            [SELECT Id, Name, Amount, StageName, CloseDate FROM Opportunity WHERE Amount > :amount]) {
                for(Opportunity o : oppts) {
                    o.StageName = stage;
                }
                //update oppts;
            }
            return;
    }
}
