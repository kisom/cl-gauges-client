TARGET := gauges
PREFIX := ${HOME}

$(TARGET):
	sbcl --load "client.lisp" --eval "(install \"$(TARGET)\")"

install:
	cp $(TARGET) ${PREFIX}/bin

clean:
	-rm -f $(TARGET) *.fasl
