/**
 * Created by Danil on 29.03.2018.
 */

/**
 * Created by Admin on 3/29/2018.
 */

public with sharing class ProductPageControllerExtension {
    Shop_Product__c prod {get; set;}
    Shop_Order__c order {get; set;}
    public Integer numOfSelected{
        get{
            return [SELECT COUNT() FROM Shop_Product_Order__c WHERE Shop_Order__c = :order.Id];
        }
        set;}

    public ProductPageControllerExtension(ApexPages.StandardController stdController){
        prod = (Shop_Product__c)stdController.getRecord();
    }

    public void initOrder(){
        Cookie cookieID = ApexPages.currentPage().getCookies().get('id');
        List<Shop_Order__c> orders = new List<Shop_Order__c>();

        if(cookieID != null){
            String cookieIDValue = cookieID.getValue();
            orders =
            [
                    SELECT
                            Id
                    FROM Shop_Order__c
                    WHERE Id = :cookieID.getValue()
            ];
        }

        if (orders.isEmpty()) {
            order = new Shop_Order__c(Status__c = 'new', Name = 'guest user order');    //хардкод нужно убрать!!!
            insert order;
            cookieID = new Cookie('id', order.Id, '/', 10000, false);
            ApexPages.currentPage().setCookies(new Cookie[]{cookieID});
        } else {
            order = orders[0];
        }
    }

    public void addToBucket(){
        List<Shop_Product_Order__c> products = [
                SELECT
                        Id
                FROM Shop_Product_Order__c
                WHERE Shop_Order__c = :order.Id AND Shop_Product__c = :prod.Id
        ];

        if (products.isEmpty()) {
            Shop_Product_Order__c newProduct = new Shop_Product_Order__c(Name = prod.Name, Shop_Order__c = order.Id,
                    Shop_Product__c = prod.Id, Quantity__c = 1);
            insert newProduct;
        }
    }
}