function(newDoc, oldDoc, userCtx, secObj) {
    if (newDoc._deleted) {
        return;
    }

    if (!newDoc.to) {
        throw ({ forbidden: 'doc.to is required' });
    }
    
    if(typeof newDoc.to !== "string"){
        throw ({ forbidden: 'doc.to is not of type string' });
    }

    if (!newDoc.from) {
        throw ({ forbidden: 'doc.from is required' });
    }

    if(typeof newDoc.from !== "string"){
        throw ({ forbidden: 'doc.from is not of type string' });
    }

    if (!newDoc.points) {
        throw ({ forbidden: 'doc.points is required' });
    }
    else {
        if (typeof newDoc.points !== 'number') {
            throw ({ forbidden: 'doc.points is not an integer' + typeof newDoc.points });
        }

        var newPoints = newDoc.points;
        while (newPoints >= 10 && newPoints % 10 == 0) {
            newPoints /= 10;
        }

        if (newPoints != 0 && newPoints != 1) {
            throw ({ forbidden: 'doc.points should be a multiple of 10 ' + newPoints});
        }
    }

    if (!newDoc.description) {
        throw ({ forbidden: 'doc.description is required' });
    }

    if(typeof newDoc.description !== "string"){
        throw ({ forbidden: 'doc.description is not of type string' });
    }

    if (!newDoc.time) {
        throw ({ forbidden: 'doc.time is required' });
    }

    if(typeof newDoc.time !== "number"){
        throw ({ forbidden: 'doc.time is not of type number' });
    }
}
