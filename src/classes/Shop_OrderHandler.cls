/**
 * Created by Admin on 4/1/2018.
 */

public with sharing class Shop_OrderHandler {

    private static void close(List<Shop_Order__c> newOrders, Map<Id, Shop_Order__c> oldOrders){
        List<Id> closedOrders = new List<Id>();

        for (Shop_Order__c order : newOrders) {
            if (oldOrders.get(order.Id).Status__c == 'Active' && order.Status__c == 'Closed') {
                closedOrders.add(order.Id);
            }
        }

        List<Shop_Product_Order__c> productOrders = [
                SELECT
                        Id
                        , Quantity__c
                        , Shop_Product__r.Total_Quantity__c
                FROM Shop_Product_Order__c
                WHERE Shop_Order__c IN :closedOrders
        ];

        List<Shop_Product__c> updatedProducts = new List<Shop_Product__c>();
        for (Shop_Product_Order__c productOrder : productOrders) {
            productOrder.Shop_Product__r.Total_Quantity__c -= productOrder.Quantity__c;
            updatedProducts.add(productOrder.Shop_Product__r);
        }
        update updatedProducts;

    }

    private static void reject(List<Shop_Order__c> newOrders, Map<Id, Shop_Order__c> oldOrders){
        List<Id> rejectedOrders = new List<Id>();

        for (Shop_Order__c order : newOrders) {
            if (oldOrders.get(order.Id).Status__c == 'Active' && order.Status__c == 'Rejected') {
                rejectedOrders.add(order.Id);
            }
        }
        List<Shop_Product_Order__c> productOrders = [
                SELECT
                        Id
                        , Quantity__c
                        , Shop_Product__r.Quantity__c
                FROM Shop_Product_Order__c
                WHERE Shop_Order__c IN :rejectedOrders
        ];
        List<Shop_Product__c> updatedProducts = new List<Shop_Product__c>();
        for (Shop_Product_Order__c productOrder : productOrders) {
            productOrder.Shop_Product__r.Quantity__c += productOrder.Quantity__c;
            updatedProducts.add(productOrder.Shop_Product__r);
        }
        update updatedProducts;

    }

    private static void preventUpdate(List<Shop_Order__c> newOrders, Map<Id, Shop_Order__c> oldOrders){
        for (Shop_Order__c order : newOrders) {
            if (oldOrders.get(order.id).Status__c == 'Closed' || oldOrders.get(order.id).Status__c == 'Rejected') {
                order.Status__c = oldOrders.get(order.id).Status__c;
            }
        }
    }

    public static void afterUpdate(List<Shop_Order__c> newOrders, Map<Id, Shop_Order__c> oldOrders){
        close(newOrders, oldOrders);
        reject(newOrders, oldOrders);
    }

    public static void beforeUpdate(List<Shop_Order__c> newOrders, Map<Id, Shop_Order__c> oldOrders){
        preventUpdate(newOrders, oldOrders);
    }
}