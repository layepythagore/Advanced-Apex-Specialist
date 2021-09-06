public class Product2Extension {
    /*
    public List<Product2> productsToInsert {get;set;}

    public Product2Extension(){
        productsToInsert = new List<Product2>();
        addRows();
    }

    public void AddRows(){
        for ( Integer i=0; i<2; i++ ){
            productsToInsert.add( new Product2() );
        }
    }

    public List<ChartHelper.ChartData> GetInventory(){
        return ChartHelper.GetInventory();
    }

    public PageReference Save(){
        try {
            insert productsToInsert;

            //If successful clear the list and display an informational message
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,productsToInsert.size()+' Inserted'));
            productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (Exception e){

        }
        return null;
    }
    */

    public List<ProductWrapper> productsToInsert {get; set;}

    public Product2Extension(Apexpages.StandardController stc){
        productsToInsert = new List<ProductWrapper>();
        AddRows();
    }

    public void AddRows(){
        for (Integer i = 0; i < Constants.DEFAULT_ROWS; i++) {
            productsToInsert.add(new ProductWrapper());
        }
    }

    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
        for (PickListEntry pickList : Constants.PRODUCT_FAMILY) {
            options.add(new SelectOption(pickList.getValue(), pickList.getValue()));
        }
        return options;
    }

    public Pagereference Save() {
        Savepoint sp = Database.setSavepoint();

        List<Product2> products = new List<Product2>();
        List<PricebookEntry> pbes = new List<PricebookEntry>();
        for (ProductWrapper prodWrap : productsToInsert) {
            if(prodWrap.productRecord != null && prodWrap.pricebookEntryRecord != null) {
                if (prodWrap.productRecord.Name != null && prodWrap.productRecord.Name != '' &&
                        prodWrap.productRecord.Family != '' && Constants.SELECT_ONE != prodWrap.productRecord.Family && 
                        prodWrap.productRecord.Initial_Inventory__c != null && prodWrap.pricebookEntryRecord.UnitPrice != null) {
                    products.add(prodWrap.productRecord);
                    PricebookEntry pbe = prodWrap.pricebookEntryRecord;
                    pbe.IsActive = true;
                    pbe.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
                    pbes.add(pbe);
                }
            }
        }

        if (products != NULL && products.size() > 0) {
            insert products;
            for (Integer i = 0; i < pbes.size(); i++) {
                pbes[i].Product2Id = products[i].Id;
            }
            if (pbes != NULL && pbes.size() > 0) {
                insert pbes;
            }
            //If successful clear the list and display an informational message
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, products.size() + ' Inserted'));
        } else {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
        }
        productsToInsert.clear();//Do not remove
        AddRows();//Do not remove
        return null;
    }

    public List<ChartHelper.ChartData> GetInventory(){
        return ChartHelper.GetInventory();
    }

    public class ProductWrapper {
        public Product2 productRecord {get; set;}
        public PricebookEntry pricebookEntryRecord {get; set;}

        public ProductWrapper() {
            productRecord = new Product2(Initial_Inventory__c = 0);
            pricebookEntryRecord = new PriceBookEntry(Unitprice = 0.0);
        }
    }
}