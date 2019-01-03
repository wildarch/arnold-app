import './main.css';
import { Elm } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';
import PouchDB from 'pouchdb-browser';

const app = Elm.Main.init({
    node: document.getElementById('root')
});

const db = new PouchDB('transactions_local');
const remote = 'http://root:password@localhost:5984/transactions';
db.replicate.from(remote, {live: true}, null);
db.replicate.to(remote, {live: true}, null);

db.changes({ live: true, include_docs: true }).on('change', function(change){
    if(change.id.startsWith('_')) {
        // Internal object
        return;
    }
    if(change.deleted) {
        app.ports.transactionChangeInternal.send({
            "deleted": {
                "id": change.id
            }
        });
    } else {
        app.ports.transactionChangeInternal.send({
            "upserted": change.doc
        });
    }
});
/*
setInterval(function(){
    db.query('points/total', { group: true}).then(function(res){
        console.log(res);
    });
}, 10000);
*/

registerServiceWorker();
