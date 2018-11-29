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
        let prevSenderBalance = await Utils.getEtherBalance(accounts[0]);
        let prevPlatformHolderBalance = await Utils.getEtherBalance(platformHolder);
        let txCost;
      await  makeTransactionKYC (
            royalty,
            web3.toWei(0.005, 'ether'),
            'fghjsdfgh',
            parseInt(new Date().getTime() / 1000),
            accounts[4],
            web3.toWei(0.005, 'ether'),
            accounts[0],
        )
          .then((result)=> Utils.getTxCost(result))
          .then((result) => txCost = result );
        let afterSenderBalance = await Utils.getEtherBalance(accounts[0]);
        let afterPlatformHolderBalance = await Utils.getEtherBalance(platformHolder);
        await Utils.checkState({ royalty }, {
            royalty: {
                name: 'Royalty',
                totalSupply: 1,
                tokenURI :[
                    {[0]: 'fghjsdfgh'},
                ]
            },
        });
        await Utils.checkEtherBalance(
            accounts[0],
            new BigNumber(prevSenderBalance).sub(txCost).sub(
                web3.toWei(0.005, 'ether')
            )
        )
        await Utils.checkEtherBalance(
            platformHolder,
            new BigNumber(prevPlatformHolderBalance).add(
                web3.toWei(0.005, 'ether')
            )
        )

        const { logs } =   await assetPurchase.purchaseDigitalAsset(
            0,
            {
                value: web3.toWei(0.005, 'ether')
            }
        )
        assert.equal(logs.length, 1);
        assert.equal(logs[0].event, 'AssetUsagePurchased');
        const digitalAssetId = logs[0].args.digitalAssetId;
        const buyer = logs[0].args.buyer;
        const amount = logs[0].args.amount;
        const purchasingTimestamp = logs[0].args.purchasingTimestamp;
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

});
