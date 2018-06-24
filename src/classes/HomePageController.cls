/**
 * Created by Danil on 28.03.2018.
 */

public with sharing class HomePageController {

//    public final Shop_Product__c shopProduct {get; set;}
    public List<Shop_Product__c> listShopProducts {get; set;}
    public String prevType = 'Laptop';
    public Integer listItems; //the number of objects of the category/type in the org
    public Integer pageSize {get; set;}
    public Integer pageNumber {get; set;}
    public Integer resultSize {
        get {
            return listItems;
        }
    }
    public Boolean hasNext {
        get {
            return pageNumber < Math.ceil(Decimal.valueOf(resultSize).divide(pageSize, 1));
        }
    }
    public Boolean hasPrevious {
        get {
            return pageNumber > 1;
        }
    }
    public Shop_Order__c shopOrder {get; set;}
    public Integer numOfSelected{
        get{
            return [SELECT COUNT() FROM Shop_Product_Order__c WHERE Shop_Order__c = :shopOrder.Id];
        }
        set;}

    //Constructor
    public HomePageController() {
        this.pageSize = 5;
        this.pageNumber = 1;
        this.numOfSelected = 0;
    }

    public void init(){
        checkCookies();
        refreshList();
    }

    public void refreshList() {
        update shopOrder;
        if (shopOrder.Selected_Type__c != prevType) {
            prevType = shopOrder.Selected_Type__c;
            pageNumber = 1;
        }
        listItems = [SELECT count()
        FROM Shop_Product__c
        WHERE Type__c = :shopOrder.Selected_Type__c
        ];

        Integer offset = (pageNumber-1)*pageSize;
        listShopProducts = [SELECT  Name
                , Brand__c
                , Description__c
                , Price__c
                , Quantity__c
                , Image__c
        FROM Shop_Product__c
        WHERE Type__c = :shopOrder.Selected_Type__c
        ORDER BY Name
        LIMIT :pageSize
        OFFSET :offset
        ];

        //If there are no items on the page
        if (listShopProducts.size() == 0 && pageNumber != 1) {
            pageNumber--;
            refreshList();
        }
    }

    public void checkCookies(){
        Cookie cookieID = ApexPages.currentPage().getCookies().get('id');
        List<Shop_Order__c> orders = new List<Shop_Order__c>();

        if(cookieID != null){
            String cookieIDValue = cookieID.getValue();
            orders =
            [
                    SELECT
                            Id
                            , Selected_Type__c
                    FROM Shop_Order__c
                    WHERE Id = :cookieID.getValue() AND Status__c = 'New'
            ];
        }

        if (orders.isEmpty()) {
            shopOrder = new Shop_Order__c(Status__c = 'new', Name = 'guest user order', Selected_Type__c = 'Laptop');    //хардкод нужно убрать!!!
            insert shopOrder;
            cookieID = new Cookie('id', shopOrder.Id, '/', 100000, false);
            ApexPages.currentPage().setCookies(new Cookie[]{cookieID});
        } else {
            shopOrder = orders[0];
        }
    }

    public void next() {
        pageNumber++;
        refreshList();
    }

    public void previous() {
        pageNumber--;
        refreshList();
    }
}