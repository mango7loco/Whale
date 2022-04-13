const nfts = require('../repo/nftList');

module.exports = {
    findAll: (req, res) => {
        if (req.query.account_address !== undefined){
            const list = nfts.filter((item) => {
                return item.owner === req.query.account_address;
            });
            return res.status(200).json(list);
        }
        return res.status(200).json(nfts);
    },
};