BEGIN
    DECLARE @CurrentDate DATETIME = GETDATE();
    
    EXEC [dbo].[PV_InvertirEnPropuesta] 
        @proposalid = 7,
        @userid = 1,
        @amount = 25000000.00,
        @investmentdate = @CurrentDate,
        @paymentmethodid = 1,
        @availablemethodid = 1,
        @currencyid = 1,
        @exchangerateid = 1

    EXEC [dbo].[PV_InvertirEnPropuesta] 
        @proposalid = 7,
        @userid = 3,
        @amount = 10000000.00,
        @investmentdate = @CurrentDate,
        @paymentmethodid = 1,
        @availablemethodid = 1,
        @currencyid = 1,
        @exchangerateid = 1

        EXEC [dbo].[PV_InvertirEnPropuesta] 
        @proposalid = 7,
        @userid = 4,
        @amount = 10000000.00,
        @investmentdate = @CurrentDate,
        @paymentmethodid = 1,
        @availablemethodid = 1,
        @currencyid = 1,
        @exchangerateid = 1

        EXEC [dbo].[PV_InvertirEnPropuesta] 
        @proposalid = 7,
        @userid = 5,
        @amount = 5000000.00,
        @investmentdate = @CurrentDate,
        @paymentmethodid = 1,
        @availablemethodid = 1,
        @currencyid = 1,
        @exchangerateid = 1
END