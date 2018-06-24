/**
 * Created by Admin on 3/28/2018.
 */

public class Shop_productHandler {
    private static void addStuff(List<Shop_Product__c> newVals){
        for (Shop_Product__c product : newVals) {
            if (product.Total_Quantity__c <= 3) {
                product.Total_Quantity__c += 5;
                product.Quantity__c += 5;
            }
        }
    }

    public static void beforeUpdate(List<Shop_Product__c> newVals){
        addStuff(newVals);
    }
}