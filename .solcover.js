module.exports = {
    skipFiles: [
        'Migrations.sol',
        'test/CampaignFabricTest.sol',
        'test/CampaignTest.sol'
    ],
    // need for dependencies
    copyNodeModules: true,
    copyPackages: [
        'zeppelin-solidity'
    ],
    dir: '.',
    norpc: false
};
