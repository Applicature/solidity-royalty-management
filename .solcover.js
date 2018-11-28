module.exports = {
    skipFiles: ['Migrations.sol'],
    // need for dependencies
    copyNodeModules: true,
    copyPackages: ['zeppelin-solidity', 'minimetoken'],
    dir: '.',
    norpc: false
};
