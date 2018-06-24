/**
 * Created by Admin on 3/28/2018.
 */

trigger Shop_ProductTrigger on Shop_Product__c (before update) {
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            Shop_productHandler.beforeUpdate(Trigger.new);
        }
    }

}