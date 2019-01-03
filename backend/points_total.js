const mapfun = function (doc) {
	  emit(doc.to, doc.points);
};

const reduce = _sum;
