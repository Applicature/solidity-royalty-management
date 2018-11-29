const Management = artifacts.require('./Management.sol');
const Cashier = artifacts.require('./Cashier.sol');
const Royalty = artifacts.require('./Royalty.sol');
const AssetPurchase = artifacts.require('./AssetPurchase.sol');

const Utils = require('./utils');
const BigNumber = require('bignumber.js');
const abi = require('ethereumjs-abi');
const BN = require('bn.js');

contract('Royalty', function (accounts) {
    const platformHolder = accounts[8];
    const platformRevenueInPercents = 10;
    const percentAbsMax = 100;

    let management,
        cashier,
        royalty,
        assetPurchase;

    function makeTransactionKYC (
        instance,
        priceInEthers,
        uri,
        dataGenerationTimestamp,
        sign,
        value,
        senderAddress
    ) {
        const h = abi.soliditySHA3(
            [
                'address',
                'uint256',
                'string',
                'uint256',
            ],
            [
                new BN(senderAddress.substr(2), 16),
                value,
                uri,
                dataGenerationTimestamp,
            ]
        );
        const sig = web3.eth.sign(sign, h.toString('hex')).slice(2);
        const r = `0x${sig.slice(0, 64)}`;
        const s = `0x${sig.slice(64, 128)}`;
        const v = web3.toDecimal(sig.slice(128, 130)) + 27;

        const data = abi.simpleEncode(
            'createDigitalAssets(uint256,string,uint256,uint8,bytes32,bytes32)',
            priceInEthers, uri, dataGenerationTimestamp, v, r, s
        );

        return instance.sendTransaction(
            {
                value: value,
                from: senderAddress,
                data: data.toString('hex'),
            }
        );
    }

    beforeEach(async function () {
        management = await Management.new(
            platformHolder,
            platformRevenueInPercents,
            percentAbsMax
        );

        royalty = await Royalty.new(management.address);

        cashier = await Cashier.new(
            management.address
        );

        assetPurchase = await AssetPurchase.new(management.address);
    });

    it('check state', async function () {
        await management.registerContract(1, cashier.address);
        await management.registerContract(2, royalty.address);
        await management.registerContract(3, assetPurchase.address);

        await management.setPermission(assetPurchase.address, 0, true);
        await management.setPermission(royalty.address, 0, true);
        await management.setPermission(accounts[4], 1, true);
        const prevSenderBalance = await Utils.getEtherBalance(accounts[0]);
        const prevPlatformHolderBalance = await Utils.getEtherBalance(platformHolder);
        let txCost;
        await makeTransactionKYC(
            royalty,
            web3.toWei(0.005, 'ether'),
            'fghjsdfgh',
            parseInt(new Date().getTime() / 1000),
            accounts[4],
            web3.toWei(0.005, 'ether'),
            accounts[0],
        )
            .then((result) => Utils.getTxCost(result))
            .then((result) => txCost = result);
        await Utils.checkState({ royalty }, {
            royalty: {
                name: 'Royalty',
                totalSupply: 1,
                tokenURI: [
                    { 0: 'fghjsdfgh' },
                ],
            },
        });

        assert.equal(
            await royalty.getEtherPriceForAsset.call(0),
            web3.toWei(0.005, 'ether'),
            'getEtherPriceForAsset is not equal'
        );
        await Utils.checkEtherBalance(
            accounts[0],
            new BigNumber(prevSenderBalance).sub(txCost).sub(
                web3.toWei(0.005, 'ether')
            )
        );
        await Utils.checkEtherBalance(
            platformHolder,
            new BigNumber(prevPlatformHolderBalance).add(
                web3.toWei(0.005, 'ether')
            )
        );

        const { logs } = await assetPurchase.purchaseDigitalAsset(
            0,
            {
                value: web3.toWei(0.005, 'ether'),
            }
        );
        assert.equal(logs.length, 1);
        assert.equal(logs[0].event, 'AssetUsagePurchased');
        const digitalAssetId = logs[0].args.digitalAssetId;
        const buyer = logs[0].args.buyer;
        const amount = logs[0].args.amount;
        assert.equal(
            digitalAssetId,
            0,
            'digitalAssetId is not equal'
        );
        assert.equal(
            buyer,
            accounts[0],
            'buyer is not equal'
        );
        assert.equal(
            amount,
            web3.toWei(0.005, 'ether'),
            'amount is not equal'
        );
    });

    it('transaction should failed if it isn\'t signed', async function () {
        await management.registerContract(1, cashier.address);
        await management.registerContract(2, royalty.address);
        await management.registerContract(3, assetPurchase.address);

        await management.setPermission(assetPurchase.address, 0, true);
        await management.setPermission(royalty.address, 0, true);
        const notSignerAddress = accounts[5];
        await management.setPermission(accounts[4], 1, true);
        await makeTransactionKYC(
            royalty,
            web3.toWei(0.005, 'ether'),
            'fghjsdfgh',
            parseInt(new Date().getTime() / 1000),
            notSignerAddress,
            web3.toWei(0.005, 'ether'),
            accounts[0]
        )
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);
    });

    it('transaction should failed if contributor  sends less/more than enough', async function () {
        await management.registerContract(1, cashier.address);
        await management.registerContract(2, royalty.address);
        await management.registerContract(3, assetPurchase.address);

        await management.setPermission(assetPurchase.address, 0, true);
        await management.setPermission(royalty.address, 0, true);
        const signerAddress = accounts[4];
        await management.setPermission(accounts[4], 1, true);
        await makeTransactionKYC(
            royalty,
            web3.toWei(0.005, 'ether'),
            'fghjsdfgh',
            parseInt(new Date().getTime() / 1000),
            signerAddress,
            web3.toWei(0.0049, 'ether'),
            accounts[0]
        )
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);
        await makeTransactionKYC(
            royalty,
            web3.toWei(0.005, 'ether'),
            'fghjsdfgh',
            parseInt(new Date().getTime() / 1000),
            signerAddress,
            web3.toWei(0.0051, 'ether'),
            accounts[0]
        )
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);
    });

    it('check set management function', async function () {
        await management.registerContract(1, cashier.address);
        await management.registerContract(2, royalty.address);
        await management.registerContract(3, assetPurchase.address);

        await management.setPermission(assetPurchase.address, 0, true);
        await management.setPermission(royalty.address, 0, true);
        assert.equal(
            await royalty.management.call(),
            management.address,
            'management is not equal'
        );
        await royalty.setManagementContract(0x0)
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);
        assert.equal(
            await royalty.management.call(),
            management.address,
            'management is not equal'
        );
        const managementNew = management = await Management.new(
            platformHolder,
            platformRevenueInPercents,
            percentAbsMax
        );
        await royalty.setManagementContract(managementNew.address)
            .then(Utils.receiptShouldSucceed);
        assert.equal(
            await royalty.management.call(),
            managementNew.address,
            'management is not equal'
        );
    });

    it('check setTransactionDataExpirationPeriod function', async function () {
        await management.registerContract(1, cashier.address);
        await management.registerContract(2, royalty.address);
        await management.registerContract(3, assetPurchase.address);

        await management.setPermission(assetPurchase.address, 0, true);
        await management.setPermission(royalty.address, 0, true);
        assert.equal(
            await management.transactionDataExpirationPeriod.call(),
            3600,
            'ExpirationPeriod is not equal'
        );
        await management.setTransactionDataExpirationPeriod(0, { from: accounts[8] })
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);
        assert.equal(
            await management.transactionDataExpirationPeriod.call(),
            3600,
            'ExpirationPeriod is not equal'
        );
        await management.setTransactionDataExpirationPeriod(5000)
            .then(Utils.receiptShouldSucceed);
        assert.equal(
            await management.transactionDataExpirationPeriod.call(),
            5000,
            'ExpirationPeriod is not equal'
        );
    });

    it('check ' +
        'setAssetRegistrationPrice' +
        'updatePlatformHolderAddress' +
        'updatePlatformPercentsRevenue' +
        ' functions', async function () {
        await management.registerContract(1, cashier.address);
        await management.registerContract(2, royalty.address);
        await management.registerContract(3, assetPurchase.address);

        await management.setPermission(assetPurchase.address, 0, true);
        await management.setPermission(royalty.address, 0, true);

        assert.equal(
            await management.assetRegistrationPrice.call(),
            web3.toWei(0.005, 'ether'),
            'assetRegistrationPrice is not equal'
        );
        await management.setAssetRegistrationPrice(0, { from: accounts[8] })
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);

        await management.setAssetRegistrationPrice(0)
            .then(Utils.receiptShouldSucceed);
        assert.equal(
            await management.assetRegistrationPrice.call(),
            0,
            'assetRegistrationPrice is not equal'
        );

        assert.equal(
            await management.platformHolderAddress.call(),
            accounts[8],
            'platformHolderAddress is not equal'
        );
        await management.updatePlatformHolderAddress(0x0, { from: accounts[0] })
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);

        await management.updatePlatformHolderAddress(accounts[7], { from: accounts[8] })
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);

        await management.updatePlatformHolderAddress(accounts[7])
            .then(Utils.receiptShouldSucceed);
        assert.equal(
            await management.platformHolderAddress.call(),
            accounts[7],
            'platformHolderAddress is not equal'
        );

        assert.equal(
            await management.platformRevenueInPercents.call().valueOf(),
            10,
            'platformPercentsRevenue is not equal'
        );
        await management.updatePlatformPercentsRevenue(112, 100, { from: accounts[0] })
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);

        await management.updatePlatformPercentsRevenue(12, 1000, { from: accounts[8] })
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);

        await management.updatePlatformPercentsRevenue(12, 1000)
            .then(Utils.receiptShouldSucceed);
        assert.equal(
            await management.platformRevenueInPercents.call(),
            12,
            'platformPercentsRevenue is not equal'
        );
        assert.equal(
            await management.percentAbsMax.call(),
            1000,
            'percentAbsMax is not equal'
        );
    });
});
