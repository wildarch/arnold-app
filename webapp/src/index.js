import './main.css';
import { Elm } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';
import PouchDB from 'pouchdb-browser';

const db = new PouchDB('transactions_local');

db.changes({ live: true, include_docs: true }).on('change', function(change){
	console.log(change);
});
db.changes({live: true, include_docs: true, filter: "_view", view: "points/total"}).on('change', function(change){
	console.log("Total change");
	console.log(change);
});
const remote = 'http://root:password@localhost:5984/transactions';
db.replicate.from(remote, {live: true}, null);
db.replicate.to(remote, {live: true}, null);
setInterval(function(){
	db.query('points/total', { group: true}).then(function(res){
		console.log(res);
	});
}, 10000);

Elm.Main.init({
  node: document.getElementById('root')
});

registerServiceWorker();
