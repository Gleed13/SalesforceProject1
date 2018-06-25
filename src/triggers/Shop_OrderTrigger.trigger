/**
 * Created by Admin on 4/1/2018.
 */

trigger Shop_OrderTrigger on Shop_Order__c(after update, before update) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            Shop_OrderHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    } else {
        if (Trigger.isUpdate) {
            Shop_OrderHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}
