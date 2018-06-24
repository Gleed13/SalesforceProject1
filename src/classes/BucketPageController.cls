/**
 * Created by Admin on 3/29/2018.
 */

public with sharing class BucketPageController {
    public Shop_Order__c shopOrder {get; set;}
    public Decimal totalPrice{
        get{
            Decimal price = 0;
            for (Shop_Product_Order__c productOrder: productOrders) {
                price += productOrder.Total_Cost__c;
            }
            return price;
        } set;}
    public List<Shop_Product_Order__c> productOrders{ get; set;}
    public Boolean tryAgain{get; set;}
    public Boolean success{get; set;}

    public BucketPageController(){
        tryAgain = false;
        success = false;
    }

    public void init(){
        initOrder();
        initContact();
        initProductOrders();
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
                            , Status__c
                            , Activate_Date__c
                            , Buyer__c
                            , Buyer__r.Id
                            , Buyer__r.LastName
                            , Buyer__r.FirstName
                            , Buyer__r.MailingCity
                            , Buyer__r.MailingStreet
                            , Buyer__r.MobilePhone
                    FROM Shop_Order__c
                    WHERE Id = :cookieID.getValue() AND Status__c = 'New'
            ];
        }

        if (orders.isEmpty()) {
            shopOrder = new Shop_Order__c(Status__c = 'new', Name = 'guest user order');    //хардкод нужно убрать!!!
            insert shopOrder;
            cookieID = new Cookie('id', shopOrder.Id, '/', 10000, false);
            ApexPages.currentPage().setCookies(new Cookie[]{cookieID});
        } else {
            shopOrder = orders[0];
        }
    }

    public void initContact(){
        if (shopOrder.Buyer__c == null) {
            shopOrder.Buyer__r = new Contact(LastName = 'not identified');
            insert shopOrder.Buyer__r;
        }
    }

    public void refreshPrices(){
        for (Shop_Product_Order__c productOrder : productOrders){
            if (productOrder.Quantity__c > productOrder.Shop_Product__r.Quantity__c) {
                productOrder.Quantity__c = productOrder.Shop_Product__r.Quantity__c;
            }
            if (productOrder.Quantity__c < 0) {
                productOrder.Quantity__c = 0;
            }
            productOrder.Sum__c = productOrder.Quantity__c * productOrder.Shop_Product__r.Price__c;
        }
        System.debug(productOrders[0].Quantity__c);
        update productOrders;
    }

    public void initProductOrders(){
        productOrders = [SELECT
                Id
                , Total_Cost__c
                , Quantity__c
                , Sum__c
                , Shop_Product__r.Name
                , Shop_Product__r.Price__c
                , Shop_Product__r.Brand__c
                , Shop_Product__r.Code__c
//                    , Shop_Product__r.Image__c
                , Shop_Product__r.Image_Path__c
                , Shop_Product__r.Quantity__c
        FROM Shop_Product_Order__c
        WHERE Shop_Order__c = :shopOrder.Id
        ];

        for (Shop_Product_Order__c productOrder : productOrders) {
//            if (productOrder.Quantity__c > productOrder.Shop_Product__r.Quantity__c) {
//                productOrder.Quantity__c = productOrder.Shop_Product__r.Quantity__c;
//            }
            productOrder.Sum__c = productOrder.Quantity__c * productOrder.Shop_Product__r.Price__c;
        }
    }

    public void delFromBucket(){
        Id delProdId = System.currentPageReference().getParameters().get('prodID');
        Shop_Product_Order__c delProduct;

        for (Shop_Product_Order__c productOrder : productOrders) { //находим нужный продукт
            if (productOrder.Id.equals(delProdId)) {
                delProduct = productOrder;
                break;
            }
        }
        System.debug(delProdId);

        if (delProduct != null) {
            delete delProduct;
            System.debug('not null');
        }
        initProductOrders();
    }

    public void submit(){
        initProductOrders();
        System.debug(productOrders[0].Quantity__c);
        //сверяем количества с тем, что в базе, если что-то изменилось, то выведем сообщение и снова эту же страницу с обновленными данными
        List<Id> selectedProducts = new List<Id>();
        for (Shop_Product_Order__c productOrder : productOrders) {
            selectedProducts.add(productOrder.Shop_Product__c);
        }
        List<Shop_Product__c> refreshedProducts = [
                SELECT
                        Id
                        , Quantity__c
                FROM Shop_Product__c
                WHERE Id IN :selectedProducts
        ];
        Map<Id, Shop_Product__c> productMap = new Map<Id, Shop_Product__c>(refreshedProducts);

        Boolean valuesValid = true;
        for (Shop_Product_Order__c productOrder : productOrders) {
            //если введенное кол-во больше того, что осталось (данные устарели)
            System.debug(productOrder.Quantity__c);
            if (productOrder.Quantity__c > productMap.get(productOrder.Shop_Product__c).Quantity__c) {
                valuesValid = false;
                break;
            } else {
                productMap.get(productOrder.Shop_Product__c).Quantity__c -= productOrder.Quantity__c;
            }
        }
        if (valuesValid) {
            success = true;
            shopOrder.Status__c = 'Active';
            shopOrder.Name = shopOrder.Buyer__r.FirstName + ' order';
            shopOrder.Buyer__c = shopOrder.Buyer__r.Id;
            update productMap.values();
            update shopOrder.Buyer__r;
            update shopOrder;
            init();
        } else {
            tryAgain = true;
        }

    }

}