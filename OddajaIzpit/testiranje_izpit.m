%record = 'eegmmidb/S005/S005R12.edf';
%record = 'eegmmidb/S020/S020R12.edf';
record = 'eegmmidb/S003/S003R03.edf';
annot = 'event';
hz= 13;
for i = 20:5:105
    ocena_praga(record, annot, i, hz)
end
hz1=30;
for i = 20:5:105
    ocena_praga(record, annot, i, hz1)
end